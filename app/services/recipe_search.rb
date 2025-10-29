class RecipeSearch
    def self.call(ingredients:, page:, per_page:)
      new(
        ingredients:   ingredients,
        page:         page,
        per_page:     per_page
      ).call
    end
  
    def initialize(ingredients:, page:, per_page:)
      @ingredients   = ingredients # ex: "tomato,salt,egg"
      @page         = (page.presence || 1).to_i
      @per_page     = (per_page.presence || 20).to_i
    end
  
    def call
      user_ingredients_array = build_normalized_user_ingredients
  
      if user_ingredients_array.empty?
        return paginated_result_from_array(fallback_recipes)
      end
  
      recipe_ing_ids, ids_to_user_ings = match_recipe_ingredients_by_user_ingredient(user_ingredients_array)
      return paginated_result_from_recipes([]) if recipe_ing_ids.empty?
  
      scored_recipes = score_recipes(recipe_ing_ids, ids_to_user_ings)
      paginated_result_from_recipes(scored_recipes)
    end
  
    private
  
    # Builds a unique, normalized list of search ingredient from the user ingredient
    # ex: "Tomato, cheese  cheese" → ["tomato", "cheese"]
    def build_normalized_user_ingredients
      normalized_ings = @ingredients
        .to_s
        .downcase
        .split(/[,\s]+/)
        .reject(&:blank?)
  
      (normalized_ings).uniq
    end

    def paginated_result_from_recipes(scored_recipes)
      total_count = scored_recipes.size
      offset      = (@page - 1) * @per_page
      slice       = scored_recipes.slice(offset, @per_page) || []
  
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
            yields:       r.yields || nil,
            total_ings:   recipe_ing_ids.size,
            matched_ings: nil,
            _score:       0.0
          }
        end
    end

    # Finds recipe ingredient ids matching each user ingredient and returns both the ids and a mapping
    def match_recipe_ingredients_by_user_ingredient(user_ingredients) 
      ids_to_user_ings = {}
    
      user_ingredients.each do |ing|
        matches = Ingredient
          .where("name ILIKE ?", "%#{ing}%") # Use ILIKE for case-insensitive search -> PostgreSQL specific
          .pluck(:id)
      
        matches.each do |ing_id|
          ids_to_user_ings[ing_id] = ing
        end
      end
    
      recipe_ing_ids = ids_to_user_ings.keys
      [recipe_ing_ids, ids_to_user_ings] # ex: [[5, 8, 15], {5=>"tomato", 8=>"tomato, egg, salt", 15=>"salt"}]
    end

    # Scores all candidate recipes based on how many distinct user ings match their ingredients 
    # ex: "salt" matches 2 ingredients → higher score
    def score_recipes(recipe_ing_ids, ids_to_user_ings)
      return [] if recipe_ing_ids.blank?

      matcher = RecipeMatcher.new(recipe_ing_ids)
      recipes = candidate_recipes(recipe_ing_ids)
      return [] if recipes.empty?

      ingredients_by_recipe = build_ingredients_map(recipes)

      scored_recipes = recipes.map do |recipe|
        scored_recipe(recipe, ingredients_by_recipe, ids_to_user_ings, matcher)
      end
    
      scored_recipes.sort_by { |h| -h[:_score] }
    end

    # Returns all recipes that include at least one of the user's ingredient ids
    def candidate_recipes(recipe_ing_ids)
      Recipe
        .joins(:recipe_ingredients)
        .where(recipe_ingredients: { ingredient_id: recipe_ing_ids })
        .distinct
    end

    # Builds a hash mapping each recipe ID to its unique list of ingredient IDs
    def build_ingredients_map(recipes)
      recipe_ids = recipes.pluck(:id)

      rows = RecipeIngredient
        .where(recipe_id: recipe_ids)
        .pluck(:recipe_id, :ingredient_id)

      ingredients_by_recipe = {}

      rows.each do |recipe_id, ingredient_id|
        (ingredients_by_recipe[recipe_id] ||= []) << ingredient_id
      end
    
      ingredients_by_recipe.transform_values!(&:uniq)
    
      ingredients_by_recipe # ex: {1=>[2,3], 2=>[4,5,6]}
    end

    # Builds a scored hash for a single recipe based on how many distinct user ingredients match its ingredients
    def scored_recipe(recipe, ingredients_by_recipe, ids_to_user_ings, matcher)
      recipe_ing_ids = ingredients_by_recipe[recipe.id] || []

      total_ings = recipe_ing_ids.size

      # Count distinct user ings matching the recipe's ingredients
      matched_user_ings = recipe_ing_ids.map { |id| ids_to_user_ings[id] }.compact.uniq
      matched_ings  = matched_user_ings.size

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