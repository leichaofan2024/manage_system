class AddColumnApplicationPassToApplication < ActiveRecord::Migration[5.1]
  def change
    add_column :applications,:application_pass,:integer,:default => 0
  end
end
