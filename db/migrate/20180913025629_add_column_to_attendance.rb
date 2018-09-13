class AddColumnToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances,:add_overtime,:integer
  end
end
