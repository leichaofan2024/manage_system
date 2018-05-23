class CreateAttendanceSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_settings do |t|
      t.string :vacation
      t.integer :count
      t.timestamps
    end
  end
end
