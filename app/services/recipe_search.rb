# app/services/recipe_search.rb
#
# RecipeSearch is the application service (use case) responsible for:
# - collecting the user's "available ingredients" (from pantry + optional query terms)
# - finding recipes that contain those ingredients
# - ranking the recipes by relevance
# - returning plain Ruby hashes ready for JSON rendering
#
# This keeps the controller thin and isolates business logic from HTTP concerns.

class RecipeSearch
    def self.call(pantry_scope:, query:, limit:)
      new(pantry_scope:, query:, limit:).call
    end
  
    def initialize(pantry_scope:, query:, limit:)
      @pantry_scope = pantry_scope
      @query        = query
      @limit        = (limit.presence || 50).to_i
    end
  
    def call
      terms = build_terms
      return fallback_recipes if terms.empty?
  
      ing_ids = match_ingredient_ids(terms)
      return [] if ing_ids.empty?
  
      ranked_recipes(ing_ids)
    end
  
    private
  
    # ------------------------------------------------------------------
    # 1. Build the "terms" we will try to match against Ingredient names
    #    - pantry ingredients already saved by the user
    #    - optional free-text search (`?q=egg,tomato`)
    # ------------------------------------------------------------------
    def build_terms
      pantry_terms = @pantry_scope
        .order(:name)
        .pluck(:name)
        .map!(&:downcase)
  
      quick_terms = @query
        .to_s
        .downcase
        .split(/[,\s]+/) # split on commas or spaces
        .reject(&:blank?)
  
      (pantry_terms + quick_terms).uniq
    end
  
    # ------------------------------------------------------------------
    # 2. Find matching ingredient ids for those terms.
    #
    # We don't do strict equality because the dataset isn't normalized.
    # Example:
    #  - Pantry says "egg"
    #  - Ingredient could be "eggs", "large egg", "1 egg"
    #
    # So we consider it a match if ingredient.name ILIKE %term%.
    # ------------------------------------------------------------------
    def match_ingredient_ids(terms)
      return [] if terms.empty?
  
      # Build something like:
      # lower(name) LIKE ? OR lower(name) LIKE ? OR ...
      where_sql  = terms.map { |t| "lower(name) LIKE ?" }.join(" OR ")
      where_args = terms.map { |t| "%#{t.downcase}%" }
  
      Ingredient.where(where_sql, *where_args).pluck(:id)
    end
  
    # ------------------------------------------------------------------
    # 3. Query recipes that include those ingredients.
    #    We compute:
    #    - total_ings: how many ingredients the recipe needs
    #    - matched_ings: how many of those the user already "has"
    #
    #    We then ORDER BY a domain-level ranking formula provided
    #    by RecipeMatcher (domain object).
    # ------------------------------------------------------------------
    def ranked_recipes(ing_ids)
      matcher = RecipeMatcher.new(ing_ids)
  
      Recipe.joins(:recipe_ingredients)
        .select(
          "recipes.id,
           recipes.title,
           recipes.image,
           recipes.total_time,
           recipes.yields,
           COUNT(recipe_ingredients.id) AS total_ings,
           SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')})
                    THEN 1 ELSE 0 END) AS matched_ings"
        )
        .group("recipes.id")
        .having("COUNT(recipe_ingredients.id) > 0")
        .order(Arel.sql(matcher.ranking_sql))
        .limit(@limit)
        .map { |r| serialize_list_item(r) }
    end
  
    # ------------------------------------------------------------------
    # 4. Fallback: if the user has no pantry items and didn't search,
    #    just return a default slice of recipes (no ranking).
    #    Still returns the same shape, so the frontend is happy.
    # ------------------------------------------------------------------
    def fallback_recipes
      Recipe
        .select(:id, :title, :image, :total_time, :yields)
        .limit(@limit)
        .map { |r|
          {
            id:            r.id,
            title:         r.title,
            image:         r.image,
            total_time:    r.total_time,
            yields:        r.yields,
            total_ings:    nil,
            matched_ings:  nil
          }
        }
    end
  
    # ------------------------------------------------------------------
    # 5. Unify the JSON shape for each recipe item
    #    (this doubles as a super-lightweight serializer)
    # ------------------------------------------------------------------
    def serialize_list_item(r)
      {
        id:            r.id,
        title:         r.title,
        image:         r.image,
        total_time:    r.total_time,
        yields:        r.yields,
        total_ings:    r.try(:total_ings)&.to_i,
        matched_ings:  r.try(:matched_ings)&.to_i
      }
    end
  end
  