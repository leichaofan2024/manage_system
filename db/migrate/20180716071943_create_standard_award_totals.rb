class CreateStandardAwardTotals < ActiveRecord::Migration[5.1]
  def change
    create_table :standard_award_totals do |t|
      t.string :序号
      t.string :科室车间
      t.string :标准化合计
      t.string :标准化科室车间
      t.string :标准化班组
      t.string :标杆优秀达标车间奖励
      t.string :科室车间备份
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
