class CreateDivideLevelWageHeads < ActiveRecord::Migration[5.1]
  def change
    create_table :divide_level_wage_heads do |t|
      t.string :divide_head_name
      t.string :head_name
      t.json :formula
      t.timestamps
    end
  end
end
