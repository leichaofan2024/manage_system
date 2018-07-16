class CreateOtherAwardTotals < ActiveRecord::Migration[5.1]
  def change
    create_table :other_award_totals do |t|
      t.string :序号
      t.string :科室车间
      t.string :排名奖励
      t.string :防止安全隐患奖励
      t.string :奖励1
      t.string :奖励2
      t.string :奖励3
      t.string :奖励4
      t.string :奖励5
      t.string :奖励6
      t.string :备注
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
