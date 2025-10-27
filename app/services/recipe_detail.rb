class RecipeDetail
  def self.call(id:)
    new(id:).call
  end

  def initialize(id:)
    @id = id
  end

  def call
    recipe = Recipe.includes(:ingredients, :recipe_ingredients).find(@id)

    {
      id:          recipe.id,
      title:       recipe.title,
      total_time:  recipe.total_time,
      yields:      recipe.yields,
      image:       recipe.image,
      url:         recipe.url,
      ingredients: serialize_ingredients(recipe)
    }
  end

  private

  def serialize_ingredients(recipe)
    recipe.recipe_ingredients.map do |ri|
      {
        id:   ri.ingredient_id,
        name: ri.ingredient.name,
        raw:  ri.raw_text
      }
    end
  end
end
  