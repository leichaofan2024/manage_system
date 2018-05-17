class CreateAttendanceRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_records do |t|
      t.string :edit_before, null: false
      t.string :edit_after, null: false
      t.integer :attendance_id, null: false
      t.integer :day, null: false
      t.string :modify_person, null: false
      t.timestamps
    end
  end
end
