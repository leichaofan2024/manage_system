class CreateEmployees < ActiveRecord::Migration[5.1]
  def change
    create_table :employees do |t|
      t.string  :sal_number,       null: false,  default: "", comment: "工资号"
      t.string  :job_number,       null: false,  comment: "工号"
      t.string  :record_number,                  comment: "档案号"
      t.string  :workshop,         null: false,  comment: "车间"
      t.string  :group,            null: false,  comment: "班组"
      t.string  :name,             null: false
      t.string  :sex,              null: false
      t.string  :birth_date,       null: false
      t.integer :birth_year,       null: false
      t.integer :age,              null: false
      t.string  :nation,           null: false,  comment: "民族"
      t.string  :native_place,                   comment: "籍贯"
      t.string  :political_role,                 comment: "政治面貌"
      t.string  :political_party_date,           comment: "党团时间"
      t.string  :working_time,                   comment: "工作时间"
      t.string  :railway_time,                   comment: "入路时间"
      t.string  :entry_time,                     comment: "本单位日期"
      t.string  :duty,                           comment: "职务"
      t.string  :employment_period,              comment: "任职时间"
      t.string  :part_time,                      comment: "兼职时间"
      t.string  :grade,                          comment: "级别"
      t.string  :promotion_leader_time,          comment: "转干时间"
      t.string  :technique_duty,                 comment: "技术职务"
      t.string  :hold_technique_time,            comment: "任技时间"
      t.string  :work_type,                      comment: "工种分类"
      t.string  :job_foreman,                    comment: "任班组长"
      t.string  :contract_station,               comment: "合同岗位"
      t.string  :three_one,                      comment: "三员一长"
      t.string  :people_source,                  comment: "人员来源"
      t.string  :people_category,                comment: "人员分类"
      t.string  :education_background,           comment: "文化程度"
      t.string  :graduation_time,                comment: "毕业时间"
      t.string  :graduation_school,              comment: "毕业院校"
      t.string  :school_sort,                    comment: "学校类别"
      t.string  :major
      t.string  :where_place,                    comment: "现在何处"
      t.string  :employment_form,                comment: "用工形式"
      t.string  :contract_period,                comment: "合同期限"
      t.string  :conclude_contract_time,         comment: "签订时间"
      t.float   :record_saler,                   comment: "档案工资"
      t.float   :skilledness_saler,              comment: "技能工资"
      t.float   :station_saler,                  comment: "岗位工资"
      t.float   :seniority_saler,                comment: "工龄工资"
      t.string  :skilledness_authenticate,       comment: "技能鉴定"
      t.string  :treatment,                      comment: "待遇"
      t.integer :sation_rank,                    comment: "岗位排序"
      t.integer :skilledness_rank,               comment: "技能排序"
      t.string  :station_now,                    comment: "现岗位"
      t.string  :station_now_time,               comment: "现岗时间"
      t.string  :retire_condition,               comment: "退休条件"
      t.string  :marriage_status,                comment: "婚姻情况"
      t.string  :separate_status,                comment: "分居情况"
      t.string  :visit_family,                   comment: "享受探亲"
      t.string  :registered_residence,           comment: "户口所在"
      t.string  :family_address,                 comment: "家庭住址"
      t.string  :comment,                        comment: "备注"
      t.string  :identity_card_number,           comment: "身份证号"
      t.string  :employee_card_number,           comment: "工作证号"
      t.string  :trade_code,                     comment: "行业代码"
      t.string  :produce_group,                  comment: "生产组"
      t.float   :saler_item,                     comment: "工资项目"
      t.float   :other_saler,                    comment: "其他工资"
      t.float   :comment_data,                   comment: "备用数据"
      t.string  :TBZ
      t.string  :PY
      t.string  :company_name,    null: false,   comment: "单位名称", default: "北京供电段"
      t.string  :CJBZPX
      t.string  :family
      t.integer :J01BF
      t.string  :duting,                         comment: "职务化"
      t.timestamps
    end
    add_index :employees, :sal_number, unique: true
  end
end
