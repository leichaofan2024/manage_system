class CreateWageHeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :wage_headers do |t|
      t.string :header
      t.timestamps
    end
  end
end
