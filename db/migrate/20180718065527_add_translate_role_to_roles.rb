class AddTranslateRoleToRoles < ActiveRecord::Migration[5.1]
  def change
    add_column :roles, :translate_role, :string,  unique: true
  end
end
