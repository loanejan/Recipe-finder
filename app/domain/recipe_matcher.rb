# app/domain/recipe_matcher.rb
#
# RecipeMatcher encapsulates the business logic for evaluating and ranking
# recipes based on how well they match the user's available ingredients.
#
# This is "domain logic": pure product rules, not HTTP or controller logic.
#
# High-level idea:
# - We want recipes where the user already has most of the ingredients.
# - We reward high match ratio (matched / total).
# - We penalize recipes that are "annoying" because they require many missing ingredients.
#
# This class provides two things:
#   - `ranking_sql`: an ORDER BY expression we can use directly in ActiveRecord.
#   - `score_for(recipe)`: a pure Ruby scorer we could call in memory if needed.

class RecipeMatcher
    attr_reader :ingredient_ids
  
    def initialize(ingredient_ids)
      # ingredient_ids is the list of Ingredient IDs that the user "has"
      # (based on pantry items and/or manual query terms)
      #
      # We fallback to [0] to avoid generating invalid SQL like "IN ()"
      @ingredient_ids = Array(ingredient_ids).presence || [0]
    end
  
    # This returns an ORDER BY clause that can be injected into ActiveRecord.
    #
    # It ranks recipes by:
    #   score = (matched_ings / total_ings) - 0.05 * (missing_ings)
    #
    # Where:
    #   matched_ings  = number of ingredients in the recipe that the user already has
    #   total_ings    = total number of ingredients in the recipe
    #   missing_ings  = total_ings - matched_ings
    #
    # We CAST the division to float so we don't do integer division.
    #
    def ranking_sql
      "
        (
          CAST(SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ingredient_ids.join(',')})
                        THEN 1 ELSE 0 END) AS float)
          / COUNT(recipe_ingredients.id)
        )
        - 0.05 * (
          COUNT(recipe_ingredients.id)
          - SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ingredient_ids.join(',')})
                     THEN 1 ELSE 0 END)
        ) DESC
      "
    end
  
    # This is a pure Ruby version of the same idea.
    # You can call this in memory on a loaded Recipe instance.
    #
    # It's useful for unit tests or for future features like "preview score".
    #
    # Expects `recipe.recipe_ingredients` to be loaded (so includes or prefetch ideally).
    #
    def score_for(recipe)
      total = recipe.recipe_ingredients.size
      return 0.0 if total.zero?
  
      matched = recipe.recipe_ingredients.count do |ri|
        ingredient_ids.include?(ri.ingredient_id)
      end
  
      missing = total - matched
  
      (matched.to_f / total) - 0.05 * missing
    end
  end
  