module Api
  class RecipesController < BaseController
    def index
      recipes = RecipeSearch.call(
        pantry_scope: PantryItem.all,
        query: params[:q],
        limit: params[:limit]
      )

      render json: recipes
    end

    def show
      recipe = RecipeDetail.call(id: params[:id])
      render json: recipe
    end
  end
end
