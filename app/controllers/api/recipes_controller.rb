module Api
  class RecipesController < BaseController
    def index
      pantry_terms = PantryItem.order(:name).pluck(:name).map!(&:downcase)
      quick_terms  = params[:q].to_s.downcase.split(/[,\s]+/).reject(&:blank?)
      terms        = (pantry_terms + quick_terms).uniq

      if terms.any?
        ing_ids = Ingredient.where(terms.map { |t| "lower(name) LIKE ?" }.join(" OR "),
                                  *terms.map { |t| "%#{t.downcase}%" }
                                  ).pluck(:id)
        ing_ids = [0] if ing_ids.empty?

        recipes = Recipe.joins(:recipe_ingredients)
          .select(
            "recipes.id, recipes.title, recipes.image, recipes.total_time, recipes.yields,
             COUNT(recipe_ingredients.id) AS total_ings,
             SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')})
                      THEN 1 ELSE 0 END) AS matched_ings"
          )
          .group("recipes.id")
          .having("COUNT(recipe_ingredients.id) > 0")
          .order(Arel.sql("
            (CAST(SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')})
                           THEN 1 ELSE 0 END) AS float)
            / COUNT(recipe_ingredients.id))
            - 0.05 * (
              COUNT(recipe_ingredients.id)
              - SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')})
                         THEN 1 ELSE 0 END)
            ) DESC
          "))
          .limit(params.fetch(:limit, 50))

        render json: recipes.as_json
      else
        render json: Recipe
          .select(:id, :title, :image, :total_time, :yields)
          .limit(50)
      end
    end

    def show
      recipe = Recipe.includes(:ingredients, :recipe_ingredients).find(params[:id])

      render json: {
        id: recipe.id,
        title: recipe.title,
        total_time: recipe.total_time,
        yields: recipe.yields,
        image: recipe.image,
        url: recipe.url,
        ingredients: recipe.recipe_ingredients.map { |ri|
          {
            id: ri.ingredient_id,
            name: ri.ingredient.name,
            raw: ri.raw_text
          }
        }
      }
    end
  end
end
