class CreateLeavingEmployees < ActiveRecord::Migration[5.1]
  def change
    create_table :leaving_employees do |t|
      t.integer :employee_id
      t.text :cause
      t.timestamps
    end
  end
end
