class ChangeEmailToUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :email, from: false, to: true
  end
end
