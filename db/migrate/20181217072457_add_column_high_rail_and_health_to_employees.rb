class AddColumnHighRailAndHealthToEmployees < ActiveRecord::Migration[5.1]
  def change
  	add_column :employees,:if_high_rails,:boolean,default: false
  	add_column :employees,:health,:string
  end
end
