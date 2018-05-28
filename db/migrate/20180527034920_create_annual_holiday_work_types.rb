class CreateAnnualHolidayWorkTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_holiday_work_types do |t|
      t.string :work_type
      t.timestamps
    end
  end
end
