class CreateProductionStuffWageHeads < ActiveRecord::Migration[5.1]
  def change
    create_table :production_stuff_wage_heads do |t|
      t.string :production_head_name
      t.string :head_name
      t.json :formula
      t.timestamps
    end
  end
end
