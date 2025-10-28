# - counts ingredients per recipe
# - counts matched ingredients
# - returns total_ings and matched_ings
#
class RecipeSearch
    def self.call(query:, page:, per_page:)
      new(
        query:        query,
        page:         page,
        per_page:     per_page
      ).call
    end
  
    def initialize(query:, page:, per_page:)
      @query        = query
      @page         = (page.presence || 1).to_i
      @per_page     = (per_page.presence || 20).to_i
    end
  
    def call
      terms = build_terms
  
      if terms.empty?
        return paginated_result_from_array(fallback_recipes)
      end
  
      all_ids, id_to_term = match_ingredients_by_term(terms)
      return paginated_result_from_array([]) if all_ids.empty?
  
      scored = score_candidates(all_ids, id_to_term)
      paginated_result_from_array(scored)
    end
  
    private
  
    # Builds a unique, normalized list of search terms from the user query
    # ex: "Tomato, cheese  cheese" → ["tomato", "cheese"]
    def build_terms
      quick_terms = @query
        .to_s
        .downcase
        .split(/[,\s]+/)
        .reject(&:blank?)
  
      (quick_terms).uniq
    end

    def paginated_result_from_array(full_array)
      total_count = full_array.size
      offset      = (@page - 1) * @per_page
      slice       = full_array.slice(offset, @per_page) || []
  
      {
        recipes: slice.map { |h| h.except(:_score) },
        pagination: {
          page:          @page,
          per_page:      @per_page,
          total_count:   total_count,
          has_next_page: (offset + @per_page) < total_count
        }
      }
    end

    def fallback_recipes
      Recipe
        .includes(:recipe_ingredients)
        .limit(100)
        .map do |r|
          recipe_ing_ids = r.recipe_ingredients.map(&:ingredient_id).uniq
  
          {
            id:           r.id,
            title:        r.title,
            image:        r.image,
            total_time:   r.total_time,
            yields:     r.yields || nil,
            total_ings:   recipe_ing_ids.size,
            matched_ings: nil,
            _score:       0.0
          }
        end
    end

    # Finds ingredient ids matching each term and returns both the ids and a mapping
    # ex: ["salt", "tomato"] → [1, 2, 5], {1=>"salt", 2=>"tomato", 5=>"tomato"}
    def match_ingredients_by_term(terms) 
      id_to_term = {}
    
      terms.each do |term|
        matches = Ingredient
          .where("name ILIKE ?", "%#{term}%") # Use ILIKE for case-insensitive search (PostgreSQL-specific)
          .pluck(:id)
      
        matches.each do |ing_id|
          id_to_term[ing_id] = term
        end
      end
    
      all_ids = id_to_term.keys
      [all_ids, id_to_term] # - id_to_term: hash { ingredient_id => utilisateur_term }
    end

    # Scores all candidate recipes based on how many distinct user terms match their ingredients 
    # ex: "salt" matches 2 ingredients → higher score
    def score_candidates(user_ing_ids, id_to_term)
      return [] if user_ing_ids.blank?

      matcher    = RecipeMatcher.new(user_ing_ids)
      candidates = candidate_recipes(user_ing_ids)
      return [] if candidates.empty?

      ingredients_by_recipe = build_ingredients_map(candidates)

      scored = candidates.map do |recipe|
        scored_recipe(recipe, ingredients_by_recipe, id_to_term, matcher)
      end
    
      scored.sort_by { |h| -h[:_score] }
    end

    # Returns all recipes that include at least one of the user's ingredient ids
    def candidate_recipes(user_ing_ids)
      Recipe
        .joins(:recipe_ingredients)
        .where(recipe_ingredients: { ingredient_id: user_ing_ids })
        .distinct
    end

    # Builds a hash mapping each recipe ID to its unique list of ingredient IDs
    # ex: {1=>[2,3], 2=>[4,5,6]}
    # A VERIFIER
    def build_ingredients_map(candidates)
      recipe_ids = candidates.pluck(:id)

      rows = RecipeIngredient
        .where(recipe_id: recipe_ids)
        .pluck(:recipe_id, :ingredient_id)

      ingredients_by_recipe = { }

      rows.each do |recipe_id, ingredient_id|
        (ingredients_by_recipe[recipe_id] ||= []) << ingredient_id
      end
    
      ingredients_by_recipe.transform_values!(&:uniq)
    
      ingredients_by_recipe
    end

    # Builds a scored hash for a single recipe based on how many distinct user terms match its ingredients
    def scored_recipe(recipe, ingredients_by_recipe, id_to_term, matcher)
      recipe_ing_ids = ingredients_by_recipe[recipe.id] || []

      total_ings = recipe_ing_ids.size

      # Count distinct user terms matching the recipe's ingredients
      matched_terms = recipe_ing_ids.map { |id| id_to_term[id] }.compact.uniq
      matched_ings  = matched_terms.size

      score = matcher.score_for(
        total_ings:   total_ings,
        matched_ings: matched_ings
      )

      {
        id:           recipe.id,
        title:        recipe.title,
        image:        recipe.image,
        total_time:   recipe.total_time,
        yields:       recipe.yields || nil,
        total_ings:   total_ings,
        matched_ings: matched_ings,
        _score:       score
      }
    end
end  