class CreatePeopleChanges < ActiveRecord::Migration[5.1]
  def change
    create_table :people_changes do |t|
      t.string :车间
      t.string :班组
      t.string :姓名
      t.string :变动原因
      t.timestamps
    end
  end
end
