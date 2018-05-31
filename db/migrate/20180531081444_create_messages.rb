class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :type
      t.text :message
      t.integer :user_id
      t.boolean :have_read
      t.timestamps
    end
  end
end
