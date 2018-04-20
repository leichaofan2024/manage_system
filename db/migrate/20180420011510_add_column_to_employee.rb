class AddColumnToEmployee < ActiveRecord::Migration[5.1]
  def change
    add_column :employees, :working_years, :integer, comment: "工作时长"
    add_column :employees, :rali_years, :integer, comment: "入路时长"
  end
end
