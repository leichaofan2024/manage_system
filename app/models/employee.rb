class Employee < ApplicationRecord

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    head_transfer = {"工资号" => "sal_number",
                     "工号" => "job_number",
                     "档案号" => "record_number",
                     "车间" => "workshop",
                     "班组" => "group",
                     "姓名" => "name",
                     "性别" => "sex",
                     "出生日期" => "birth_date",
                     "出生年份" => "birth_year",
                     "年龄" => "age",
                     "民族" => "nation",
                     "籍贯" => "native_place",
                     "政治面目" => "political_role",
                     "党团时间" => "political_party_date",
                     "工作时间" => "working_time",
                     "入路时间" => "railway_time",
                     "本单位日期" => "entry_time",
                     "职务" => "duty",
                     "任职时间" => "employment_period",
                     "兼职" => "part_time",
                     "级别" => "grade",
                     "转干时间" => "promotion_leader_time",
                     "技术职务" => "technique_duty",
                     "任技时间" => "hold_technique_time",
                     "工种分类" => "work_type",
                     "任班组长" => "job_foreman",
                     "合同岗位" => "contract_station",
                     "三员一长" => "three_one",
                     "人员来源" => "people_source",
                     "人员分类" => "people_category",
                     "文化程度" => "education_background",
                     "毕业时间" => "graduation_time",
                     "毕业学校" => "graduation_school",
                     "学校类别" => "school_sort",
                     "所学专业" => "major",
                     "现在何处" => "where_place",
                     "用工形式" => "employment_form",
                     "合同期限" => "contract_period",
                     "签订时间" => "conclude_contract_time",
                     "档案工资" => "record_saler",
                     "技能工资" => "skilledness_saler",
                     "岗位工资" => "station_saler",
                     "工龄工资" => "seniority_saler",
                     "技能鉴定" => "skilledness_authenticate",
                     "待遇"    => "treatment",
                     "岗位档序" => "station_rank",
                     "技能档序" => "skilledness_rank",
                     "现岗位"   => "station_now",
                     "现岗时间" => "station_now_time",
                     "退休条件" => "retire_condition",
                     "婚况"    => "marriage_status",
                     "分居情况" => "separate_status",
                     "享受探亲" => "visit_family",
                     "户口所在" => "registered_residence",
                     "家庭住址" => "family_address",
                     "备注"    => "comment",
                     "身份证号" => "identity_card_number",
                     "工作证号" => "employee_card_number",
                     "行业代码" => "trade_code",
                     "生产组"  => "produce_group",
                     "工资项目" => "saler_item",
                     "其他工资" => "other_saler",
                     "备用数据" => "comment_data",
                     "TBZ"    => "TBZ",
                     "PY"     => "PY",
                     "单位名称" => "company_name",
                     "CJBZPX" => "CJBZPX",
                     "家属"   => "family",
                     "J01BF" => "J01BF",
                     "职务化" => "duting",
                   }
    header = spreadsheet.row(1).map{ |i| head_transfer[i]}
    (2..spreadsheet.last_row).each do |j|
      row = Hash[[header, spreadsheet.row(j)].transpose]
      employee = find_by(id: row["id"]) || new
      employee.attributes = row.to_hash
      employee.save!
    end
  end
end