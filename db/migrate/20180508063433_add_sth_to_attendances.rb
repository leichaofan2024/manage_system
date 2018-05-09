class AddSthToAttendances < ActiveRecord::Migration[5.1]
  def change
  	add_column :attendances, :employee_id, :integer
  end
end
