class CreateEmpBasicInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :emp_basic_infos, comment: "员工基本信息表" do |t|
      t.string      :sal_number,                 comment: "工资号"
      t.string      :workshop,                   comment: "车间"
      t.string      :group,                      comment: "班组"
      t.string      :name,                       comment: "姓名"
      t.string      :job_number,                 comment: "工号"
      t.integer     :sex, limit: 1, default: 1,  comment: "性别: 1-男， 2-女"
      t.string      :identity_card_number,       comment: "身份证号"
      t.integer     :age,                        comment: "年龄"
      t.string      :duty,                       comment: "职务"
      t.timestamps
    end
  end
end
