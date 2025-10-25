module Api
  class RecipesController < BaseController
    def index
      result = RecipeSearch.call(
        pantry_scope: PantryItem.all,
        query: params[:q],
        page: params[:page],
        per_page: params[:per_page]
      )

      render json: result
    end

    def show
      recipe = RecipeDetail.call(id: params[:id])
      render json: recipe
    end
  end
end
