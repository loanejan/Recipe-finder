class DropPantryItems < ActiveRecord::Migration[8.1]
  def up
    drop_table :pantry_items
  end

  def down
    create_table :pantry_items do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pantry_items, :name
  end
end
