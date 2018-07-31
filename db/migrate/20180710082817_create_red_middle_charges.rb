class CreateRedMiddleCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :red_middle_charges do |t|
      t.string :序号
      t.string :姓名
      t.string :工资号
      t.string :部门
      t.string :核减金额
      t.string :备注
      t.timestamps
    end
  end
end
