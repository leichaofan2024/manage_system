class AddUploadTimeToChargeDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :charge_details, :upload_time, :date
  end
end
