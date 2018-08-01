class AddColumnToGroup < ActiveRecord::Migration[5.1]
  def change
  	add_column :groups, :status, :boolean, default: "1"
  end
end
