class RenameColumnOnEmpBasicInfo < ActiveRecord::Migration[5.1]
  def change
    rename_column :emp_basic_infos, :workshop, :workshop_id
    rename_column :emp_basic_infos, :group, :group_id
  end
end
