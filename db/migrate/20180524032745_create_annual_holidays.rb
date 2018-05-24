class CreateAnnualHolidays < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_holidays do |t|
      t.integer :employee_id
      t.integer :holiday_days
      t.integer :month_1
      t.integer :month_2
      t.integer :month_3
      t.integer :month_4
      t.integer :month_5
      t.integer :month_6
      t.integer :month_7
      t.integer :month_8
      t.integer :month_9
      t.integer :month_10
      t.integer :month_11
      t.integer :month_12
      t.timestamps
    end
  end
end
