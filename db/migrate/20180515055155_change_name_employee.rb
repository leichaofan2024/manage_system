class ChangeNameEmployee < ActiveRecord::Migration[5.1]
  def change
  	rename_column :employees, :workshop_id, :workshop
  	rename_column :employees, :group_id, :group
  end
end
