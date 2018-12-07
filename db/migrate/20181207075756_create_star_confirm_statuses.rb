class CreateStarConfirmStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :star_confirm_statuses do |t|
      t.integer :year
      t.integer :quarter
      t.boolean :status, default: 0
      t.timestamps
    end
  end
end
