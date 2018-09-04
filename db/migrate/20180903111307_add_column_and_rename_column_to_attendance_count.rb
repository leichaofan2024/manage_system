class AddColumnAndRenameColumnToAttendanceCount < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendance_counts,:vacation_code
    rename_column :attendance_counts,:count,:a
    add_column  :attendance_counts,:b,:integer
    add_column  :attendance_counts,:c,:integer
    add_column  :attendance_counts,:d,:integer
    add_column  :attendance_counts,:e,:integer
    add_column  :attendance_counts,:f,:integer
    add_column  :attendance_counts,:g,:integer
    add_column  :attendance_counts,:h,:integer
    add_column  :attendance_counts,:i,:integer
    add_column  :attendance_counts,:j,:integer
    add_column  :attendance_counts,:k,:integer
    add_column  :attendance_counts,:l,:integer
    add_column  :attendance_counts,:m,:integer
    add_column  :attendance_counts,:n,:integer
    add_column  :attendance_counts,:o,:integer
    add_column  :attendance_counts,:p,:integer
    add_column  :attendance_counts,:q,:integer
    add_column  :attendance_counts,:r,:integer
    add_column  :attendance_counts,:s,:integer
    add_column  :attendance_counts,:t,:integer
    add_column  :attendance_counts,:u,:integer
    add_column  :attendance_counts,:v,:integer
    add_column  :attendance_counts,:w,:integer
    add_column  :attendance_counts,:y,:integer
    add_column  :attendance_counts,:z,:integer

  end
end
