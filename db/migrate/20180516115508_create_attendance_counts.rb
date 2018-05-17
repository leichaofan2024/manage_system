class CreateAttendanceCounts < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_counts do |t|
      t.integer :attendance_id, null: false
      t.string :vacation_code, null: false
      t.integer :count, default: 0, null: false
      t.timestamps
    end
  end
end
