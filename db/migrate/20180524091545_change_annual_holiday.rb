class ChangeAnnualHoliday < ActiveRecord::Migration[5.1]
  def change
  	remove_column :annual_holidays, :month_1
  	remove_column :annual_holidays, :month_2
  	remove_column :annual_holidays, :month_3
  	remove_column :annual_holidays, :month_4
  	remove_column :annual_holidays, :month_5
  	remove_column :annual_holidays, :month_6
  	remove_column :annual_holidays, :month_7
  	remove_column :annual_holidays, :month_8
  	remove_column :annual_holidays, :month_9
  	remove_column :annual_holidays, :month_10
  	remove_column :annual_holidays, :month_11
  	remove_column :annual_holidays, :month_12
  	add_column :annual_holidays, :month, :integer
  end
end
