class AddColumnApplicationBeforeAndApplicationAfterToApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :applications, :application_before,:string
    add_column :applications, :application_after,:string
  end
end
