class DropColumnFromLeavingEmployee < ActiveRecord::Migration[5.1]
  def change
  	remove_column :leaving_employees, :start_time
  	remove_column :leaving_employees, :end_time
  end
end
