class RenameEmployee < ActiveRecord::Migration[5.1]
  def change
  	rename_column :employees, :workshop, :workshop_id
  	rename_column :employees, :group, :group_id
  end
end
