class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.string   :month_attendances, limit: 62
      t.timestamps
    end
  end
end
