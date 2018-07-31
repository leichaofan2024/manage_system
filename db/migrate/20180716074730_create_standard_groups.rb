class CreateStandardGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :standard_groups do |t|
      t.string :序号
      t.string :科室车间
      t.string :班组名称
      t.string :评定等级
      t.string :奖励标准
      t.string :人数
      t.string :奖励金额
      t.string :备注
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
