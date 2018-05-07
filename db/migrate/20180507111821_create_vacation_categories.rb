class CreateVacationCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :vacation_categories do |t|
      t.string   :vacation_categories
      t.timestamps
    end
  end
end
