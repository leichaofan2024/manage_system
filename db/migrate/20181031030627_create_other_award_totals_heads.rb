class CreateOtherAwardTotalsHeads < ActiveRecord::Migration[5.1]
  def change
    create_table :other_award_totals_heads do |t|
      t.string :name
      t.string :col_name
      t.string :upload_year
      t.string :upload_month 
      t.timestamps
    end
  end
end
