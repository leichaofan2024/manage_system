class AddColumnToWorkshop < ActiveRecord::Migration[5.1]
  def change
  	add_column :workshops, :status, :boolean
  end
end
