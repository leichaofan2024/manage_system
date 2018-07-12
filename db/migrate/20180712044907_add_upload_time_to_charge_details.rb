class AddUploadTimeToChargeDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :charge_details, :upload_year, :string
    add_column :charge_details, :upload_month, :string
  end
end
