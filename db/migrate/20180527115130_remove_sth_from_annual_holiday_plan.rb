class RemoveSthFromAnnualHolidayPlan < ActiveRecord::Migration[5.1]
  def change
  	remove_column :annual_holiday_plans, :other_this_year_people_number
  end
end
