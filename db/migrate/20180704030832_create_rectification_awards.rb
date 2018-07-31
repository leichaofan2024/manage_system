class CreateRectificationAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :rectification_awards do |t|
      t.string :序号
      t.string :科室车间
      t.string :整改返奖合计
      t.string :牌卡返奖
      t.string :中层返奖
      t.string :班组长返奖
      t.string :抽考返奖
      t.string :其他返奖
      t.string :备注
      t.timestamps
    end
  end
end
