class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.string :message_type
      t.text :message
      t.integer :user_id
      t.boolean :have_read
      t.datetime :remind_time
      t.timestamps
    end
  end
end
