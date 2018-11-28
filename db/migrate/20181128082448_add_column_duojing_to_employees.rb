class AddColumnDuojingToEmployees < ActiveRecord::Migration[5.1]
  def change
  	add_column :employees,:duojing,:boolean,default: false
  end
end
