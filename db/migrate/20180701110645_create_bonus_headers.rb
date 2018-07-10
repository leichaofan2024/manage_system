class CreateBonusHeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :bonus_headers do |t|
      t.string :header
      t.timestamps
    end
  end
end
