class AddAvatarToEmployee < ActiveRecord::Migration[5.1]
  def change
  	add_column :employees, :avatar, :string
  end
end
