class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :total_time
      t.string :yields
      t.string :image
      t.string :url

      t.timestamps
    end
  end
end
