class Employee < ActiveRecord::Base
  # 不同的角色可以对Employee的资源进行不同的操作
  resourcify

  #上传照片
  mount_uploader :avatar, AvatarUploader

  has_many :attendances
  has_one :info, class_name: "EmpBasicInfo", dependent: :destroy
  has_many :attendance_counts
  has_many :annual_holidays
  has_one :leaving_employee

  scope :at_that_time, ->(year,month){where.not(:id => LeavingEmployee.where(:leaving_type => ["调离", "退休"]).where("updated_at < ?","#{year}-#{month}-15".to_time.beginning_of_month).pluck("employee_id"))}
  #去掉调离和退休的所有人
  scope :current, -> { where.not(:id => LeavingEmployee.where(:leaving_type => ["调离", "退休"]).pluck("employee_id"))}
  #所有调离的人
  scope :leaving, -> { where(:id => LeavingEmployee.where(:leaving_type => "调离").pluck("employee_id"))}
  #一段时间内所有调动的人
  scope :transfer, ->(start_time, end_time){where(:id => LeavingEmployee.where(:leaving_type => "调动").where("leaving_employees.created_at > ? AND leaving_employees.created_at < ?", start_time, end_time ).pluck("leaving_employees.employee_id"))}
  #所有退休的人
  scope :retire, -> { where(:id => LeavingEmployee.where(:leaving_type => "退休").pluck("employee_id"))}
  #所有工人
  scope :worker, -> { where(grade: nil)}
  #所有干部
  scope :cadre, -> {where.not(grade: nil)}

  scope :search_records, -> (params){self.search(params).records }

  def self.head_transfer
     return {
              "sal_number" => "工资号",
              "job_number" =>  "工号",
              "record_number" => "档案号",
              "workshop" => "部门" ,
              "group" => "班组名称",
              "group_category" => "班组类别",
              "name" =>  "姓名",
              "sex" => "性别" ,
              "birth_date" =>  "出生日期",
              "birth_year" =>  "出生年份",
              "age" =>  "年龄",
              "nation" =>  "民族",
              "native_place" =>  "籍贯",
              "political_role" =>  "政治面目",
              "political_party_date" =>  "党团时间",
              "working_time" => "工作时间" ,
              "railway_time" => "入路时间",
              "entry_time" => "本单位日期",
              "duty" => "职务",
              "employment_period" => "任职时间",
              "part_time" =>  "兼职" ,
              "grade" => "级别",
              "promotion_leader_time" =>  "转干时间",
              "technique_duty" => "技术职务" ,
              "hold_technique_time" =>  "任技时间",
              "work_type" => "工种分类",
              "job_foreman_category" => "班组长类别",
              "job_foreman_duty" =>  "班组长职务",
              "job_foreman" => "任班组长",
              "contract_station" => "合同岗位",
              "three_one" => "三员一长",
              "people_source" => "人员来源",
              "people_category" => "人员分类",
              "education_background" =>  "文化程度",
              "graduation_time" => "毕业时间",
              "graduation_school" => "毕业学校",
              "school_sort" => "学校类别",
              "major" => "所学专业",
              "where_place" => "现在何处",
              "employment_form" => "用工形式",
              "contract_period" => "合同期限",
              "conclude_contract_time" => "签订时间",
              "record_saler" => "档案工资",
              "skilledness_saler" => "技能工资" ,
              "station_saler" => "岗位工资",
              "seniority_saler" =>  "工龄工资",
              "skilledness_authenticate" =>  "技能鉴定",
              "treatment" => "待遇" ,
              "station_rank" => "岗位档序",
              "skilledness_rank" => "技能档序",
              "station_now" => "现岗位",
              "station_now_time" =>   "现岗时间",
              "retire_condition" => "退休条件",
              "marriage_status" => "婚况" ,
              "separate_status" => "分居情况",
              "visit_family" => "享受探亲",
              "registered_residence" =>  "户口所在",
              "family_address" => "家庭住址",
              "comment" => "备注" ,
              "identity_card_number" =>  "身份证号",
              "employee_card_number" => "工作证号",
              "trade_code" =>  "行业代码",
              "produce_group" => "生产组",
              "saler_item" => "工资项目",
              "other_saler" =>  "其他工资",
              "comment_data" => "备用数据" ,
              "TBZ" =>  "TBZ",
              "PY" =>  "PY",
              "company_name" =>  "单位名称",
              "CJBZPX" => "CJBZPX",
              "family" =>  "家属",
              "J01BF" =>   "J01BF",
              "duting" => "职务化",
            "working_years" => "工作时长",
             "rali_years" => "入路时长",
               "phone_number"=> "电话号码"
           }
  end
  #某个时间段调动的人
  def self.transfer_search(start_time, end_time)
    b = {"to" => [], "from" => []}
    a = LeavingEmployee.where("leaving_employees.leaving_type = ?", "调动").group_by{|u| u.employee_id}
    a.each do |employee_id, leaving_employees|
      m = LeavingEmployee.where(id: leaving_employees.map{|u| u.id}).where("leaving_employees.created_at > ? AND leaving_employees.created_at < ?", start_time, end_time).select("id", "employee_id", "transfer_to_workshop", "transfer_to_group", "created_at").order("created_at").last
      n = LeavingEmployee.where(id: leaving_employees.map{|u| u.id}).where("leaving_employees.created_at > ?", end_time).select("id", "employee_id", "transfer_from_workshop", "transfer_from_group", "created_at").order("created_at").first
      q = LeavingEmployee.where(id: leaving_employees.map{|u| u.id}).where("leaving_employees.created_at < ?", start_time).select("id", "employee_id", "transfer_to_workshop", "transfer_to_group", "created_at").order("created_at").last
      if m.present?
        b["to"] << m.id
      elsif n.nil?
        b["to"] << q.id
      elsif q.nil?
        b["from"] << n.id
      else
        b["to"] << q.id
      end
    end
    return b
  end

  def self.import_table(file)
    message           = {}
    spreadsheet       = Roo::Spreadsheet.open(file.path)
    head_transfer     = self.head_transfer_for_upload_form
    header            = spreadsheet.row(1).map{ |i| head_transfer[i]}

    message = self.check_column_for_upload_form(header, spreadsheet)
    return message if message.present?
    (2..spreadsheet.last_row).each do |j|
      row                             = Hash[[header, spreadsheet.row(j)].transpose]
      employee                        = find_by(sal_number: row["sal_number"]) || new
      employee.attributes             = row
      employee.job_number             = ("1" + row["job_number"].to_s).to_i.to_s[1..50]
      employee.sal_number             = '41' + employee.job_number.to_s
      employee.birth_date             = ("1" + row["birth_date"].to_s).to_i.to_s[1..50]
      employee.birth_year             = employee.birth_date[0..3]
      employee.phone_number           = ("1" + row["phone_number"].to_s).to_i.to_s[1..50]
      employee.age                    = Time.now.year - employee.birth_year.to_i
      employee.working_time           = ("1" + row["working_time"].to_s).to_i.to_s[1..50]
      employee.railway_time           = ("1" + row["railway_time"].to_s).to_i.to_s[1..50]
      employee.entry_time             = ("1" + row["entry_time"].to_s).to_i.to_s[1..50]
      employee.employment_period      = ("1" + row["employment_period"].to_s).to_i.to_s[1..50]
      employee.promotion_leader_time  = ("1" + row["promotion_leader_time"].to_s).to_i.to_s[1..50]
      employee.hold_technique_time    = ("1" + row["hold_technique_time"].to_s).to_i.to_s[1..50]
      employee.graduation_time        = ("1" + row["graduation_time"].to_s).to_i.to_s[1..50]
      employee.conclude_contract_time = ("1" + row["conclude_contract_time"].to_s).to_i.to_s[1..50]
      employee.station_now_time       = ("1" + row["station_now_time"].to_s).to_i.to_s[1..50]
      employee.record_number          = ("1" + row["record_number"].to_s).to_i.to_s[1..50]
      employee.political_party_date   = ("1" + row["political_party_date"].to_s).to_i.to_s[1..50]

      working_years_transfer          = (Time.now - employee.working_time.to_time)/60/60/24/365
      rali_years_transfer             = (Time.now - employee.railway_time.to_time)/60/60/24/365
      employee.working_years          = working_years_transfer.to_i
      employee.rali_years             = rali_years_transfer.to_i
      # 更新Workshop数据
      workshop = Workshop.current.find_by(name: row["workshop"])
      if !workshop.present?
        workshop_new = Workshop.create!(:name => row["workshop"])
        group_new = Group.create!(:name => row["group"], :workshop_id => workshop_new.id)
        employee.workshop = workshop_new.id
        employee.group = group_new.id

      else
        group = Group.current.find_by(:workshop_id => workshop.id,:name => row["group"] )
        if !group.present?
          group_new = Group.create!(:name => row["group"], :workshop_id => workshop.id)
          employee.group = group_new.id
        else
          employee.group = group.id
        end
        employee.workshop = workshop.id
      end
      employee.save!
    end
    return message
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |employee|
        csv << employee.attributes.values_at(*column_names)
      end
    end
  end

  def self.head_transfer_for_upload_form
    head_transfer               = {}
    head_transfer["工资号"]     = "sal_number"
    head_transfer["工号"]       = "job_number"
    head_transfer["档案号"]     = "record_number"
    head_transfer["部门"]       = "workshop"
    head_transfer["班组名称"]   = "group"
    head_transfer["班组类别"]   = "group_category"
    head_transfer["姓名"]       = "name"
    head_transfer["性别"]       = "sex"
    head_transfer["电话号"]     = "phone_number"
    head_transfer["出生日期"]   = "birth_date"
    head_transfer["出生年份"]   = "birth_year"
    head_transfer["年龄"]       = "age"
    head_transfer["民族"]       = "nation"
    head_transfer["籍贯"]       = "native_place"
    head_transfer["政治面目"]   = "political_role"
    head_transfer["党团时间"]   = "political_party_date"
    head_transfer["工作时间"]   = "working_time"
    head_transfer["入路时间"]   = "railway_time"
    head_transfer["本单位日期"] = "entry_time"
    head_transfer["职务"]       = "duty"
    head_transfer["任职时间"]   = "employment_period"
    head_transfer["兼职"]       = "part_time"
    head_transfer["级别"]       = "grade"
    head_transfer["转干时间"]   = "promotion_leader_time"
    head_transfer["技术职务"]   = "technique_duty"
    head_transfer["任技时间"]   = "hold_technique_time"
    head_transfer["工种分类"]   = "work_type"
    head_transfer["班组长类别"] = "job_foreman_category"
    head_transfer["班组长职务"] = "job_foreman_duty"
    head_transfer["任班组长"]   = "job_foreman"
    head_transfer["合同岗位"]   = "contract_station"
    head_transfer["三员一长"]   = "three_one"
    head_transfer["人员来源"]   = "people_source"
    head_transfer["人员分类"]   = "people_category"
    head_transfer["文化程度"]   = "education_background"
    head_transfer["毕业时间"]   = "graduation_time"
    head_transfer["毕业学校"]   = "graduation_school"
    head_transfer["学校类别"]   = "school_sort"
    head_transfer["所学专业"]   = "major"
    head_transfer["现在何处"]   = "where_place"
    head_transfer["用工形式"]   = "employment_form"
    head_transfer["合同期限"]   = "contract_period"
    head_transfer["签订时间"]   = "conclude_contract_time"
    head_transfer["档案工资"]   = "record_saler"
    head_transfer["技能工资"]   = "skilledness_saler"
    head_transfer["岗位工资"]   = "station_saler"
    head_transfer["工龄工资"]   = "seniority_saler"
    head_transfer["技能鉴定"]   = "skilledness_authenticate"
    head_transfer["待遇"]       = "treatment"
    head_transfer["岗位档序"]   = "station_rank"
    head_transfer["技能档序"]   = "skilledness_rank"
    head_transfer["现岗位"]     = "station_now"
    head_transfer["现岗时间"]   = "station_now_time"
    head_transfer["退休条件"]   = "retire_condition"
    head_transfer["婚况"]       = "marriage_status"
    head_transfer["分居情况"]   = "separate_status"
    head_transfer["享受探亲"]   = "visit_family"
    head_transfer["户口所在"]   = "registered_residence"
    head_transfer["家庭住址"]   = "family_address"
    head_transfer["备注"]       = "comment"
    head_transfer["身份证号"]   = "identity_card_number"
    head_transfer["工作证号"]   = "employee_card_number"
    head_transfer["行业代码"]   = "trade_code"
    head_transfer["生产组"]     = "produce_group"
    head_transfer["工资项目"]   = "saler_item"
    head_transfer["其他工资"]   = "other_saler"
    head_transfer["备用数据"]   = "comment_data"
    head_transfer["TBZ"]        = "TBZ"
    head_transfer["PY"]         = "PY"
    head_transfer["单位名称"]   = "company_name"
    head_transfer["CJBZPX"]     = "CJBZPX"
    head_transfer["家属"]       = "family"
    head_transfer["J01BF"]      = "J01BF"
    head_transfer["职务化"]     = "duting"
    return head_transfer
  end

  def self.check_column_for_upload_form(header, spreadsheet)
    message           = {}
    job_number_empty  = []
    job_number_repeat = []
    new_workshop      = []
    new_group         = []
    new_head          = []
    must_column_empty = []

    spreadsheet.row(1).each do |form_column|
      if self.head_transfer_for_upload_form.keys.include?(form_column)
        next
      end
      new_head << form_column
    end

    if new_head.present?
      message[:new_head] = "表头名为#{new_head}的栏位名与系统不一致，请核对后再上传！"
      return message
    end

    already_sal_number = Employee.pluck(:sal_number)
    workshop_all       = Workshop.pluck(:name)
    (2..spreadsheet.last_row).each do |row_number|
      row_content = Hash[[header, spreadsheet.row(row_number)].transpose]
      if row_content["job_number"].blank?
        job_number_empty << row_number
        next
      end
      job_number = ("1" + row_content["job_number"].to_s).to_i.to_s[1..50]
      sal_number = '41' + job_number

      if already_sal_number.include?(sal_number)
        job_number_repeat << row_number
        next
      end
      if row_content["name"].blank?
        must_column_empty << row_number
      elsif row_content["sex"].blank?
        must_column_empty << row_number
      elsif row_content["workshop"].blank?
        must_column_empty << row_number
      elsif row_content["group"].blank?
        must_column_empty << row_number
      elsif row_content["duty"].blank?
        must_column_empty << row_number
      elsif row_content["birth_date"].blank?
        must_column_empty << row_number
      elsif row_content["working_time"].blank?
        must_column_empty << row_number
      elsif row_content["railway_time"].blank?
        must_column_empty << row_number
      elsif row_content["work_type"].blank?
        must_column_empty << row_number
      elsif row_content["education_background"].blank?
        must_column_empty << row_number
      end
      next if must_column_empty.present?

      if !workshop_all.include?(row_content["workshop"])
        new_workshop << row_number
        next
      end

      wrokshop_id = Workshop.find_by(:name => row_content["workshop"]).id
      group_all   = Group.where(:workshop_id => wrokshop_id).pluck(:name)
      if !group_all.include?(row_content["group"])
        new_group << row_number
      end
    end

    if job_number_empty.present?
      message[:job_number_empty] = "上传失败！表格中第#{job_number_empty}行中《工号》这一栏不能为空！"
    elsif job_number_repeat.present?
      message[:job_number_repeat] = "上传失败！表格中第#{job_number_repeat}行中工号在系统中已存在！请核对后再上传！"
    elsif must_column_empty.present?
      message[:must_column_empty] = "上传失败！表中第#{must_column_empty}行中《姓名、性别、职务、部门、班组名称、出生日期、工作时间、入路时间、工种分类、文化程度》等栏位不能为空！"
    elsif new_workshop.present?
      message[:new_workshop] = "上传失败！表中第#{new_workshop}行中车间名称与系统不符，请核对后再上传！"
    elsif new_group.present?
      message[:new_group] = "上传失败！表中第#{new_group}行中班组名称与系统不符，请核对后再上传！"
    end

    return message
  end

end
