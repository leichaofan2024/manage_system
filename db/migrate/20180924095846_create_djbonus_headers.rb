class CreateDjbonusHeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :djbonus_headers do |t|
      t.string :header
      t.json :formula
      t.timestamps
    end
  end
end
