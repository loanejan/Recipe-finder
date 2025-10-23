class CreatePantryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :pantry_items do |t|
      t.string :name

      t.timestamps
    end
  end
end
