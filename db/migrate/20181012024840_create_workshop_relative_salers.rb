class CreateWorkshopRelativeSalers < ActiveRecord::Migration[5.1]
  def change
    create_table :workshop_relative_salers do |t|
      t.string  :序号
      t.string  :科室车间
      t.string  :姓名
      t.string  :工资号
      t.integer  :挂钩工资
      t.integer  :安全质量
      t.integer  :工作质量
      t.integer  :行车
      t.integer  :整改返奖
      t.integer  :一体化
      t.integer  :兼职兼岗
      t.integer  :考核扣款
      t.integer  :其他
      t.integer  :应发
      t.integer  :小计
      t.string   :备注
      t.string  :upload_year
      t.string  :upload_month
      t.timestamps
    end
  end
end
