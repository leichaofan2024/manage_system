class AddSomeColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :workshop_id, :integer
    add_column :users, :group_id,    :integer
  end
end
