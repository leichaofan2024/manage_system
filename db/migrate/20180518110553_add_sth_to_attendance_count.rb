class AddSthToAttendanceCount < ActiveRecord::Migration[5.1]
  def change
  	rename_column :attendance_counts, :attendance_id, :employee_id
  	add_column :attendance_counts, :year, :integer
  	add_column :attendance_counts, :month, :integer
  	add_column :attendance_counts, :group_id, :integer
  	add_column :attendance_counts, :workshop_id, :integer
  end
end
