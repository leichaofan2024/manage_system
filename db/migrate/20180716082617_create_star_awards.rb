class CreateStarAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :star_awards do |t|
      t.string :科室车间
      t.string :序号
      t.string :发放合计
      t.string :总人数
      t.string :五星岗
      t.string :四星岗
      t.string :三星岗
      t.string :二星岗
      t.string :一星岗
      t.string :五星人数
      t.string :四星人数
      t.string :三星人数
      t.string :二星人数
      t.string :一星人数
      t.string :备注
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
