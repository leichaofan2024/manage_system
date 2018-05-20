class AddColumnToAttendanceStatus < ActiveRecord::Migration[5.1]
  def change
  	add_column :attendance_statuses, :group_id, :integer
  	change_column_null :attendance_statuses, :workshop_id, :null => true
  end
end
