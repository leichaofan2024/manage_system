class CreateTeamleaderAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :teamleader_awards do |t|
      t.string :序号
      t.string :车间
      t.string :班组
      t.string :工资号
      t.string :姓名
      t.string :性别
      t.string :金额
      t.timestamps
    end
  end
end
