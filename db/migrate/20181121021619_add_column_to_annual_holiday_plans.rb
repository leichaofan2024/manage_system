class AddColumnToAnnualHolidayPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :annual_holiday_plans,:orgnization_id,:integer
  end
end
