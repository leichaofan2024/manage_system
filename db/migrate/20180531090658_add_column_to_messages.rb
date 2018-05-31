class AddColumnToMessages < ActiveRecord::Migration[5.1]
  def change
  	add_column :messages, :remind_time, :datetime
  end
end
