class CreateLeavingCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :leaving_categories do |t|
      t.string :name
      t.timestamps
    end
  end
end
