class RenameAttendanceStatus < ActiveRecord::Migration[5.1]
  def change
  	rename_column :attendance_statuses, :group_id, :workshop_id
  end
end
