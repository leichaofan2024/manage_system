class AddColumnToStarApplication < ActiveRecord::Migration[5.1]
  def change
  	add_column :star_applications, :treatment_state, :string
  end
end
