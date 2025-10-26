# app/services/recipe_search.rb
#
# Use case: return a (paginated) list of recipes ranked by how well
# they match the user's available ingredients.
#
# Now supports pagination via page / per_page instead of a single limit.
#
class RecipeSearch
    def self.call(pantry_scope:, query:, page:, per_page:)
      new(pantry_scope:, query:, page:, per_page:).call
    end
  
    def initialize(pantry_scope:, query:, page:, per_page:)
      @pantry_scope = pantry_scope
      @query        = query
      @page         = (page.presence || 1).to_i
      @per_page     = (per_page.presence || 20).to_i
    end
  
    def call
      terms = build_terms
  
      if terms.empty?
        return paginated_result_from_array(fallback_recipes)
      end
  
      ing_ids = match_ingredient_ids(terms)
      return paginated_result_from_array([]) if ing_ids.empty?
  
      scored = score_candidates_in_ruby(ing_ids)
      paginated_result_from_array(scored)
    end
  
    private
  
    # 1. collect search terms from pantry + optional query
    def build_terms
      pantry_terms = @pantry_scope
        .order(:name)
        .pluck(:name)
        .map!(&:downcase)
  
      quick_terms = @query
        .to_s
        .downcase
        .split(/[,\s]+/)
        .reject(&:blank?)
  
      (pantry_terms + quick_terms).uniq
    end
  
    # 2. get ingredient IDs whose name roughly matches those terms
    def match_ingredient_ids(terms)
      return [] if terms.empty?
  
      where_sql  = terms.map { |t| "lower(name) LIKE ?" }.join(" OR ")
      where_args = terms.map { |t| "%#{t.downcase}%" }
  
      Ingredient.where(where_sql, *where_args).pluck(:id)
    end
  
    # 3. Load candidate recipes that contain at least one of these ingredients,
    #    score them in Ruby (pure domain logic), and build hashes.
    def score_candidates_in_ruby(ing_ids)
      matcher = RecipeMatcher.new(ing_ids)
  
      candidates = Recipe
        .joins(:recipe_ingredients)
        .where(recipe_ingredients: { ingredient_id: ing_ids })
        .includes(:recipe_ingredients)
        .distinct
  
      candidates.map do |recipe|
        total_ings = recipe.recipe_ingredients.size
        matched_ings = recipe.recipe_ingredients.count { |ri| ing_ids.include?(ri.ingredient_id) }
        score = matcher.score_for(recipe)
  
        {
          id:           recipe.id,
          title:        recipe.title,
          image:        recipe.image,
          total_time:   recipe.total_time,
          yields:     recipe.yields || "N/A",
          total_ings:   total_ings,
          matched_ings: matched_ings,
          _score:       score
        }
      end
      .sort_by { |h| -h[:_score] } # high score first
    end
  
    # 4. if no pantry / no query: default list (no score, no ranking)
    def fallback_recipes
      Recipe
        .select(:id, :title, :image, :total_time, :yields)
        .map { |r|
          {
            id:           r.id,
            title:        r.title,
            image:        r.image,
            total_time:   r.total_time,
            yields:     r.yields || "N/A",
            total_ings:   nil,
            matched_ings: nil,
            _score:       0.0
          }
        }
    end
  
    # 5. take a full array of hashes (already sorted),
    #    and return ONLY the slice for the current page,
    #    plus pagination metadata.
    #
    def paginated_result_from_array(full_array)
      total_count = full_array.size
  
      offset = (@page - 1) * @per_page
      paginated_slice = full_array.slice(offset, @per_page) || []
  
      {
        recipes: paginated_slice.map { |h| h.except(:_score) },
        pagination: {
          page: @page,
          per_page: @per_page,
          total_count: total_count,
          has_next_page: offset + @per_page < total_count
        }
      }
    end
  end
  