class CreateHolidayStartTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :holiday_start_times do |t|
      t.integer :sal_number
      t.string :name
      t.string :vacation
      t.datetime :start_time
      t.timestamps
    end
  end
end
