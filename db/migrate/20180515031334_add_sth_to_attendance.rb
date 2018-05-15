class AddSthToAttendance < ActiveRecord::Migration[5.1]
  def change
  	add_column :attendances, :year, :integer, null: false
  	add_column :attendances, :group_id, :integer, null: false
  	change_column :attendances, :month_attendances, :string, null: false, default: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  end
end
