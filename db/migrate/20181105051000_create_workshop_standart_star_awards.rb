class CreateWorkshopStandartStarAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :workshop_standart_star_awards do |t|
      t.string :序号
      t.string :科室车间
      t.string :班组
      t.string :工资号
      t.string :姓名
      t.string :标准化
      t.string :星级岗
      t.string :备注
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
