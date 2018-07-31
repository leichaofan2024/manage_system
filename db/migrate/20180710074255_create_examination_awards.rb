class CreateExaminationAwards < ActiveRecord::Migration[5.1]
  def change
    create_table :examination_awards, comment: "抽考返奖表" do |t|
      t.string :序号
      t.string :工资编号
      t.string :姓名
      t.string :车间
      t.string :金额
      t.string :备注
      t.timestamps
    end
  end
end
