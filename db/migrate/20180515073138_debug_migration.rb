class DebugMigration < ActiveRecord::Migration[5.1]
  def change
    create_table :workshops do |t|
      t.string :name
      t.timestamps
    end

    create_table :groups do |t|
      t.string :name
      t.integer :workshop_id
      t.timestamps
    end

    add_column :attendances, :year, :integer, null: false
  	add_column :attendances, :group_id, :integer, null: false
  	change_column :attendances, :month_attendances, :string, null: false, default: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

    create_table :attendance_records do |t|
      t.string :edit_beforem, null: false
      t.string :edit_after, null: false
      t.integer :attendance_id, null: false
      t.integer :day, null: false
      t.string :modify_person, null: false
      t.timestamps
    end

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

    create_table :attendance_statuses do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :group_id, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
