class RecipeSearch
  def self.call(query:, page:, per_page:)
    new(
      query:    query,
      page:     page,
      per_page: per_page
    ).call
  end

  def initialize(query:, page:, per_page:)
    @query    = query
    @page     = (page.presence || 1).to_i
    @per_page = (per_page.presence || 20).to_i
  end

  def call
    terms = build_terms_from_query_only

    if terms.empty?
      # si l'utilisateur n'a rien cherché, on renvoie juste du fallback
      return paginated_result_from_array(fallback_recipes)
    end

    ing_ids = match_ingredient_ids(terms)
    return paginated_result_from_array([]) if ing_ids.empty?

    scored = score_candidates_in_ruby(ing_ids)
    paginated_result_from_array(scored)
  end

  private

  # 1. On ne regarde plus le pantry, juste la query utilisateur.
  def build_terms_from_query_only
    @query
      .to_s
      .downcase
      .split(/[,\s]+/)
      .reject(&:blank?)
      .uniq
  end

  # 2. inchangé
  def match_ingredient_ids(terms)
    return [] if terms.empty?

    where_sql  = terms.map { |t| "lower(name) LIKE ?" }.join(" OR ")
    where_args = terms.map { |t| "%#{t.downcase}%" }

    Ingredient.where(where_sql, *where_args).pluck(:id)
  end

  # 3. inchangé sauf le nom de l'arg
  def score_candidates_in_ruby(user_ing_ids)
    matcher = RecipeMatcher.new(user_ing_ids)

    candidates = Recipe
      .joins(:recipe_ingredients)
      .where(recipe_ingredients: { ingredient_id: user_ing_ids })
      .includes(:recipe_ingredients)
      .distinct

    candidates.map do |recipe|
      recipe_ing_ids = recipe.recipe_ingredients.map(&:ingredient_id).uniq

      total_ings   = recipe_ing_ids.size
      matched_ings = recipe_ing_ids.count { |iid| user_ing_ids.include?(iid) }

      score = matcher.score_for(
        total_ings:   total_ings,
        matched_ings: matched_ings
      )

      {
        id:           recipe.id,
        title:        recipe.title,
        image:        recipe.image,
        total_time:   recipe.total_time,
        servings:     recipe.yields || nil,
        total_ings:   total_ings,
        matched_ings: matched_ings,
        _score:       score
      }
    end
    .sort_by { |h| -h[:_score] }
  end

  # 4. fallback_recipes reste utile pour le cas q vide
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
          servings:     r.yields || nil,
          total_ings:   recipe_ing_ids.size,
          matched_ings: nil,
          _score:       0.0
        }
      end
  end

  # 5. pagination identique
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
end
