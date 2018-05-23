class RenameAttendanceRecord < ActiveRecord::Migration[5.1]
  def change
  	rename_column :attendance_records, :edit_beforem, :edit_before
  end
end
