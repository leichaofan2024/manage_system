class AddUploadTimeToChargeDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :charge_details, :upload_year, :string
    add_column :charge_details, :upload_month, :string

    add_column :relative_salers, :upload_year, :string
    add_column :relative_salers, :upload_month, :string

    add_column :rectification_awards, :upload_year, :string
    add_column :rectification_awards, :upload_month, :string

    add_column :middle_awards, :upload_year, :string
    add_column :middle_awards, :upload_month, :string

    add_column :teamleader_awards, :upload_year, :string
    add_column :teamleader_awards, :upload_month, :string

    add_column :other_awards, :upload_year, :string
    add_column :other_awards, :upload_month, :string

    add_column :examination_awards, :upload_year, :string
    add_column :examination_awards, :upload_month, :string

    add_column :examination_charges, :upload_year, :string
    add_column :examination_charges, :upload_month, :string

    add_column :red_middle_charges, :upload_year, :string
    add_column :red_middle_charges, :upload_month, :string

    add_column :people_changes, :upload_year, :string
    add_column :people_changes, :upload_month, :string
  end
end
