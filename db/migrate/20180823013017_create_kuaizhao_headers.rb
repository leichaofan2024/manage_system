class CreateKuaizhaoHeaders < ActiveRecord::Migration[5.1]
  def change
    create_table :kuaizhao_headers do |t|
      t.string :content_name
      t.string :header_name
      t.json :formula
      t.string :category
      t.integer :year
      t.integer :month
      t.timestamps
    end
  end
end
