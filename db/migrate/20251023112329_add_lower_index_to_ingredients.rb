class AddLowerIndexToIngredients < ActiveRecord::Migration[8.1]
  def change
    add_index :ingredients, "lower(name)", unique: true, name: "index_ingredients_on_lower_name"
  end
end
