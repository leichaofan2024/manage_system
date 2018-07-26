class CreateHighSpeedRailStuffHeads < ActiveRecord::Migration[5.1]
  def change
    create_table :high_speed_rail_stuff_heads do |t|
      t.string :high_head_name
      t.string :head_name
      t.json :formula
      t.timestamps
    end
  end
end
