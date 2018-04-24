class AddSomeColumnToEmployee < ActiveRecord::Migration[5.1]
  def change
    add_column :employees, :group_category, :string, comment: "班组类别"
    add_column :employees, :job_foreman_category, :string, comment: "班组长类别"
    add_column :employees, :job_foreman_duty, :string, comment: "班组长职务"
  end
end
