class CreateAttendanceStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_statuses do |t|
      t.integer :year
      t.integer :month
      t.integer :group_id, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
