# app/domain/recipe_matcher.rb
#
# Pure domain logic for scoring how relevant a recipe is
# given a set of available ingredient IDs.
#
# NOTE:
# - This class NO LONGER knows anything about SQL.
# - It's just "how to compute a score" for a recipe.
#
class RecipeMatcher
    attr_reader :ingredient_ids
  
    def initialize(ingredient_ids)
      # Ingredient IDs the user "has"
      @ingredient_ids = Array(ingredient_ids).presence || [0]
    end
  
    # Compute a numeric score for a recipe instance, in Ruby.
    #
    # score = (matched / total) - penalty_for_missing
    #
    # Where penalty_for_missing = 0.05 * missing_count
    #
    # Higher is better.
    #
    # Expects recipe.recipe_ingredients (and thus ingredient_id) to be loaded.
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
  