class AddTwoColumnToEmployee < ActiveRecord::Migration[5.1]
  def change
    add_column :employees, :group_id, :integer
    add_column :employees, :workshop_id, :integer
  end
end
