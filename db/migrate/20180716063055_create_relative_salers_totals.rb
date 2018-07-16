class CreateRelativeSalersTotals < ActiveRecord::Migration[5.1]
  def change
    create_table :relative_salers_totals do |t|
      t.string  :序号
      t.string  :科室车间
      t.string  :挂钩工资
      t.string  :安全质量
      t.string  :工作质量
      t.string  :行车
      t.string  :整改返奖
      t.string  :一体化
      t.string  :兼职兼岗
      t.string  :考核扣款
      t.string  :其他
      t.string  :应发
      t.string  :小计
      t.string  :备注
      t.string  :upload_year
      t.string  :upload_month
      t.timestamps
    end
  end
end
