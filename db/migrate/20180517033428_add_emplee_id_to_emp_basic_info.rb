class AddEmpleeIdToEmpBasicInfo < ActiveRecord::Migration[5.1]
  def change
    add_column :emp_basic_infos, :employee_id, :integer, null: false
    add_index  :emp_basic_infos, :employee_id, unique: true
  end
end
