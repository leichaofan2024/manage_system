class CreateOtherAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :other_awards do |t|
      t.string :序号
      t.string :工资号
      t.string :姓名
      t.string :车间
      t.string :返奖金额
      t.string :备注
      t.timestamps
    end
  end
end
