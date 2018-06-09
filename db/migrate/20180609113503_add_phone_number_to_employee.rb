class AddPhoneNumberToEmployee < ActiveRecord::Migration[5.1]
  def change
  	add_column :employees, :phone_number, :string
  end
end
