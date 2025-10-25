# app/services/recipe_detail.rb
#
# RecipeDetail is the application service for the "show recipe" use case.
#
# It returns a complete hash describing a single recipe, including:
# - basic metadata (title, total_time, yields, url, image)
# - all its ingredients, with both normalized name and raw text
#
# The controller can then just `render json: ...`
#
# This keeps controllers thin and gives us a single place to evolve
# if we later add more detail (instructions, nutrition, etc.).

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
  