class AddSthToAnnualHolidayPlan < ActiveRecord::Migration[5.1]
  def change
  	add_column :annual_holiday_plans, :status, :string
  end
end
