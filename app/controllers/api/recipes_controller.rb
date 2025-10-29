module Api
  class RecipesController < BaseController
    def index
      result = RecipeSearch.call(
        ingredients: params[:ing],
        page: params[:page],
        per_page: params[:per_page]
      )

      render json: result
      
      rescue StandardError => e
        render json: { error: "Search failed", details: e.message }, status: :unprocessable_entity
    end

    def show
      recipe = RecipeDetail.call(id: params[:id])
      render json: recipe

      rescue ActiveRecord::RecordNotFound
        render json: { error: "Recipe not found" }, status: :not_found
    end
  end
end
