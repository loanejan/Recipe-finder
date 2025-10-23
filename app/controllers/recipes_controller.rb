class RecipesController < ApplicationController
  def index
    @pantry = PantryItem.order(:name).pluck(:name)
    quick = params[:q].to_s.downcase.split(/[,\s]+/).reject(&:blank?)
    pantry = (@pantry + quick).map(&:downcase).uniq

    if pantry.any?
      ing_ids = Ingredient.where(name: pantry).pluck(:id)
      ing_ids = [0] if ing_ids.empty? # évite SQL vide

      @recipes = Recipe.joins(:recipe_ingredients)
        .select("recipes.*,
                 COUNT(recipe_ingredients.id) AS total_ings,
                 SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')}) THEN 1 ELSE 0 END) AS matched_ings")
        .group("recipes.id")
        .having("COUNT(recipe_ingredients.id) > 0")
        .order(Arel.sql("
          (CAST(SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')}) THEN 1 ELSE 0 END) AS float) / COUNT(recipe_ingredients.id))
          - 0.05 * (COUNT(recipe_ingredients.id) - SUM(CASE WHEN recipe_ingredients.ingredient_id IN (#{ing_ids.join(',')}) THEN 1 ELSE 0 END)) DESC
        "))
        .limit(50)
    else
      @recipes = Recipe.limit(50)
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
