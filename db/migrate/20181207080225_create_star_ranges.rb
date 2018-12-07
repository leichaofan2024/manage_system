class CreateStarRanges < ActiveRecord::Migration[5.1]
  def change
    create_table :star_ranges do |t|
      t.integer :name
      t.string :type
      t.float :value, default: 0.0
      t.float :money, default: 0.0
      t.timestamps
    end
  end
end
