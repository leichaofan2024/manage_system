class AddMonthToAttendances < ActiveRecord::Migration[5.1]
  def change
  	add_column :attendances, :month, :integer
  end
end
