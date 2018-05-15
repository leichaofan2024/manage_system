class CreateApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :applications do |t|
      t.string :status, null: false
      t.integer :group_id, null: false
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :day, null: false
      t.string :employee_id, array: true, default: '{}', null: false
      t.string :apply_person, null: false
      t.text :cause, null: false
      t.timestamps
    end
  end
end
