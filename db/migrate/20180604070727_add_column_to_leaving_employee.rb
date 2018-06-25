class AddColumnToLeavingEmployee < ActiveRecord::Migration[5.1]
  def change
  	add_column :leaving_employees, :leaving_type, :string
  	add_column :leaving_employees, :transfer_from_workshop, :integer
  	add_column :leaving_employees, :transfer_from_group, :integer
  	add_column :leaving_employees, :transfer_to_workshop, :integer
  	add_column :leaving_employees, :transfer_to_group, :integer
  	add_column :leaving_employees, :start_time, :datetime
  	add_column :leaving_employees, :end_time, :datetime
  end
end
