class AddColumnToAnnualHolidays < ActiveRecord::Migration[5.1]
  def change
  	add_column :annual_holidays, :year, :integer
  end
end
