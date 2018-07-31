class CreateMainDrivingStuffHeads < ActiveRecord::Migration[5.1]
  def change
    create_table :main_driving_stuff_heads do |t|
      t.string :main_head_name
      t.string :head_name
      t.json :formula
      t.timestamps
    end
  end
end
