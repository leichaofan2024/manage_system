class AddSthToVacationCategories < ActiveRecord::Migration[5.1]
  def change
  	add_column :vacation_categories, :vacation_shortening, :string, comment: "假期简称"
  	add_column :vacation_categories, :vacation_code, :string, comment: "假期代码"
  	rename_column :vacation_categories, :vacation_categories, :vacation_name
  end
end
