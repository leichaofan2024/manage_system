class CreateAnnualHolidays < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_holidays do |t|
      t.integer :employee_id
      t.integer :holiday_days
      t.integer :year
      t.integer :month
      t.timestamps
    end
  end
end
