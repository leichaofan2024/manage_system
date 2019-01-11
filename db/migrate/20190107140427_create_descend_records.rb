class CreateDescendRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :descend_records do |t|
      t.integer :year
      t.integer :quarter
      t.integer :sal_number
      t.integer :application_id
      t.string :descend_type
      t.timestamps
    end
  end
end
