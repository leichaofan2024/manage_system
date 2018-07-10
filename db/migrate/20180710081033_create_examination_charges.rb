class CreateExaminationCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :examination_charges do |t|
      t.string :序号
      t.string :工资编号
      t.string :车间
      t.string :姓名
      t.string :金额
      t.string :签字
      t.timestamps
    end
  end
end
