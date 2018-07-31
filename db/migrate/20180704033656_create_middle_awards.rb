class CreateMiddleAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :middle_awards, comment: "中层干部返奖明细表" do |t|
      t.string :序号
      t.string :姓名
      t.string :工资号
      t.string :部门
      t.string :返奖金额
      t.string :备注
      t.timestamps
    end
  end
end
