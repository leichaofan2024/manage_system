class AddColumnToAnnualHolidayPlan < ActiveRecord::Migration[5.1]
  def change
  	add_column :annual_holiday_plans, :year, :integer
  end
end
