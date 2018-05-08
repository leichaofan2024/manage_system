# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180508020939) do

  create_table "attendances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "month_attendances", limit: 62
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emp_basic_infos", primary_key: "emp_id", id: :integer, comment: "唯一标识", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "员工基本信息表" do |t|
    t.string "sal_number", comment: "工资号"
    t.string "workshop", comment: "车间"
    t.string "group", comment: "班组"
    t.string "name", comment: "姓名"
    t.string "job_number", comment: "工号"
    t.integer "sex", limit: 1, default: 1, comment: "性别: 1-男， 2-女"
    t.string "identity_card_number", comment: "身份证号"
    t.integer "age", comment: "年龄"
    t.string "duty", comment: "职务"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "sal_number", default: "", collation: "utf8mb4_bin", comment: "工资号"
    t.string "job_number", null: false, comment: "工号"
    t.string "record_number", comment: "档案号"
    t.string "workshop", null: false, comment: "车间"
    t.string "group", null: false, comment: "班组"
    t.string "name", null: false
    t.string "sex", null: false
    t.string "birth_date", null: false
    t.integer "birth_year"
    t.integer "age"
    t.string "nation", null: false, comment: "民族"
    t.string "native_place", comment: "籍贯"
    t.string "political_role", comment: "政治面貌"
    t.string "political_party_date", comment: "党团时间"
    t.string "working_time", comment: "工作时间"
    t.string "railway_time", comment: "入路时间"
    t.string "entry_time", comment: "本单位日期"
    t.string "duty", comment: "职务"
    t.string "employment_period", comment: "任职时间"
    t.string "part_time", comment: "兼职时间"
    t.string "grade", comment: "级别"
    t.string "promotion_leader_time", comment: "转干时间"
    t.string "technique_duty", comment: "技术职务"
    t.string "hold_technique_time", comment: "任技时间"
    t.string "work_type", comment: "工种分类"
    t.string "job_foreman", comment: "任班组长"
    t.string "contract_station", comment: "合同岗位"
    t.string "three_one", comment: "三员一长"
    t.string "people_source", comment: "人员来源"
    t.string "people_category", comment: "人员分类"
    t.string "education_background", comment: "文化程度"
    t.string "graduation_school", comment: "毕业院校"
    t.string "school_sort", comment: "学校类别"
    t.string "major"
    t.string "where_place", comment: "现在何处"
    t.string "employment_form", comment: "用工形式"
    t.string "contract_period", comment: "合同期限"
    t.string "conclude_contract_time", comment: "签订时间"
    t.float "record_saler", limit: 24, comment: "档案工资"
    t.float "skilledness_saler", limit: 24, comment: "技能工资"
    t.float "station_saler", limit: 24, comment: "岗位工资"
    t.float "seniority_saler", limit: 24, comment: "工龄工资"
    t.string "skilledness_authenticate", comment: "技能鉴定"
    t.string "treatment", comment: "待遇"
    t.integer "station_rank", comment: "岗位排序"
    t.integer "skilledness_rank", comment: "技能排序"
    t.string "station_now", comment: "现岗位"
    t.string "station_now_time", comment: "现岗时间"
    t.string "retire_condition", comment: "退休条件"
    t.string "marriage_status", comment: "婚姻情况"
    t.string "separate_status", comment: "分居情况"
    t.string "visit_family", comment: "享受探亲"
    t.string "registered_residence", comment: "户口所在"
    t.string "family_address", comment: "家庭住址"
    t.string "comment", comment: "备注"
    t.string "identity_card_number", comment: "身份证号"
    t.string "employee_card_number", comment: "工作证号"
    t.string "trade_code", comment: "行业代码"
    t.string "produce_group", comment: "生产组"
    t.float "saler_item", limit: 24, comment: "工资项目"
    t.float "other_saler", limit: 24, comment: "其他工资"
    t.float "comment_data", limit: 24, comment: "备用数据"
    t.string "TBZ"
    t.string "PY"
    t.string "company_name", default: "北京供电段", null: false, comment: "单位名称"
    t.string "CJBZPX"
    t.string "family"
    t.integer "J01BF"
    t.string "duting", comment: "职务化"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "graduation_time"
    t.integer "position"
    t.integer "working_years", comment: "工作时长"
    t.integer "rali_years", comment: "入路时长"
    t.string "group_category", comment: "班组类别"
    t.string "job_foreman_category", comment: "班组长类别"
    t.string "job_foreman_duty", comment: "班组长职务"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "email", default: "1", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacation_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "vacation_categories"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
