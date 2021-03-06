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

ActiveRecord::Schema.define(version: 20190107140427) do

  create_table "announcements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "title"
    t.text "content"
    t.integer "user_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "annual_holiday_plans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "workshop_id"
    t.integer "work_type", comment: "工种"
    t.integer "last_year_people_number", comment: "上年末单位人数"
    t.integer "this_year_people_number", comment: "今年休年休假人数"
    t.integer "five_days", comment: "休5天人数"
    t.integer "ten_days", comment: "休10天人数"
    t.integer "fifteen_days", comment: "休15天人数"
    t.integer "holiday_days", comment: "应休假天数"
    t.integer "January_plan_number", comment: "一月份安排人数"
    t.integer "January_plan_days", comment: "一月份休假天数"
    t.integer "February_plan_number", comment: "二月份安排人数"
    t.integer "February_plan_days", comment: "二月份休假天数"
    t.integer "March_plan_number", comment: "三月份安排人数"
    t.integer "March_plan_days", comment: "三月份休假天数"
    t.integer "April_plan_number", comment: "四月份安排人数"
    t.integer "April_plan_days", comment: "四月份休假天数"
    t.integer "May_plan_number", comment: "五月份安排人数"
    t.integer "May_plan_days", comment: "五月份休假天数"
    t.integer "June_plan_number", comment: "六月份安排人数"
    t.integer "June_plan_days", comment: "六月份休假天数"
    t.integer "July_plan_number", comment: "七月份安排人数"
    t.integer "July_plan_days", comment: "七月份休假天数"
    t.integer "August_plan_number", comment: "八月份安排人数"
    t.integer "August_plan_days", comment: "八月份休假天数"
    t.integer "September_plan_number", comment: "九月份安排人数"
    t.integer "September_plan_days", comment: "九月份休假天数"
    t.integer "October_plan_number", comment: "十月份安排人数"
    t.integer "October_plan_days", comment: "十月份休假天数"
    t.integer "November_plan_number", comment: "十一月份安排人数"
    t.integer "November_plan_days", comment: "十一月份休假天数"
    t.integer "December_plan_number", comment: "十二月份安排人数"
    t.integer "December_plan_days", comment: "十二月份休假天数"
    t.string "status"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "orgnization_id"
  end

  create_table "annual_holiday_work_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "work_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "annual_holidays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.integer "holiday_days"
    t.integer "year"
    t.integer "month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "status", null: false
    t.integer "group_id", null: false
    t.integer "year", null: false
    t.integer "month", null: false
    t.integer "day", null: false
    t.string "employee_id", default: "{}", null: false
    t.string "apply_person", null: false
    t.text "cause", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application_before"
    t.string "application_after"
    t.integer "application_pass", default: 0
  end

  create_table "attendance_counts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id", null: false
    t.integer "a", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.integer "month"
    t.integer "group_id"
    t.integer "workshop_id"
    t.integer "b"
    t.integer "c"
    t.integer "d"
    t.integer "e"
    t.integer "f"
    t.integer "g"
    t.integer "h"
    t.integer "i"
    t.integer "j"
    t.integer "k"
    t.integer "l"
    t.integer "m"
    t.integer "n"
    t.integer "o"
    t.integer "p"
    t.integer "q"
    t.integer "r"
    t.integer "s"
    t.integer "t"
    t.integer "u"
    t.integer "v"
    t.integer "w"
    t.integer "y"
    t.integer "z"
  end

  create_table "attendance_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "edit_before", null: false
    t.string "edit_after", null: false
    t.integer "attendance_id", null: false
    t.integer "day", null: false
    t.string "modify_person", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendance_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "vacation"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendance_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "year"
    t.integer "month"
    t.integer "workshop_id"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
  end

  create_table "attendances", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "month_attendances", default: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employee_id"
    t.integer "month"
    t.integer "year", null: false
    t.integer "group_id", null: false
    t.integer "add_overtime"
  end

  create_table "basic_scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "year"
    t.integer "quarter"
    t.string "workshop"
    t.string "group"
    t.string "name"
    t.string "sal_number"
    t.string "duty"
    t.float "theory_score", limit: 24, default: 0.0
    t.float "theory_weighted_score", limit: 24, default: 0.0
    t.float "practical_score", limit: 24, default: 0.0
    t.float "practical_weighted_score", limit: 24, default: 0.0
    t.float "work_performance", limit: 24, default: 0.0
    t.float "work_performance_weighted_score", limit: 24, default: 0.0
    t.float "extra_score", limit: 24, default: 0.0
    t.string "extra_score_reason"
    t.float "final_score", limit: 24, default: 0.0
    t.string "team_leader"
    t.boolean "confirm_status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bonus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.integer "month"
    t.integer "year"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.string "col4"
    t.string "col5"
    t.string "col6"
    t.string "col7"
    t.float "col8", limit: 24
    t.float "col9", limit: 24
    t.float "col10", limit: 24
    t.float "col11", limit: 24
    t.float "col12", limit: 24
    t.float "col13", limit: 24
    t.float "col14", limit: 24
    t.float "col15", limit: 24
    t.float "col16", limit: 24
    t.float "col17", limit: 24
    t.float "col18", limit: 24
    t.float "col19", limit: 24
    t.float "col20", limit: 24
    t.float "col21", limit: 24
    t.float "col22", limit: 24
    t.float "col23", limit: 24
    t.float "col24", limit: 24
    t.float "col25", limit: 24
    t.float "col26", limit: 24
    t.float "col27", limit: 24
    t.float "col28", limit: 24
    t.float "col29", limit: 24
    t.float "col30", limit: 24
    t.float "col31", limit: 24
    t.float "col32", limit: 24
    t.float "col33", limit: 24
    t.float "col34", limit: 24
    t.float "col35", limit: 24
    t.float "col36", limit: 24
    t.float "col37", limit: 24
    t.float "col38", limit: 24
    t.float "col39", limit: 24
    t.float "col40", limit: 24
    t.float "col41", limit: 24
    t.float "col42", limit: 24
    t.float "col43", limit: 24
    t.float "col44", limit: 24
    t.float "col45", limit: 24
    t.float "col46", limit: 24
    t.float "col47", limit: 24
    t.float "col48", limit: 24
    t.float "col49", limit: 24
    t.float "col50", limit: 24
    t.float "col51", limit: 24
    t.float "col52", limit: 24
    t.float "col53", limit: 24
    t.float "col54", limit: 24
    t.float "col55", limit: 24
    t.float "col56", limit: 24
    t.float "col57", limit: 24
    t.float "col58", limit: 24
    t.float "col59", limit: 24
    t.float "col60", limit: 24
    t.float "col61", limit: 24
    t.float "col62", limit: 24
    t.float "col63", limit: 24
    t.float "col64", limit: 24
    t.float "col65", limit: 24
    t.float "col66", limit: 24
    t.float "col67", limit: 24
    t.float "col68", limit: 24
    t.float "col69", limit: 24
    t.float "col70", limit: 24
    t.float "col71", limit: 24
    t.float "col72", limit: 24
    t.float "col73", limit: 24
    t.float "col74", limit: 24
    t.float "col75", limit: 24
    t.float "col76", limit: 24
    t.float "col77", limit: 24
    t.float "col78", limit: 24
    t.float "col79", limit: 24
    t.float "col80", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bonus_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "header"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "formula"
  end

  create_table "charge_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "考核扣款明细表" do |t|
    t.string "序号"
    t.string "科室车间"
    t.integer "扣款合计"
    t.integer "安全业绩扣款"
    t.integer "生产经营绩效扣款"
    t.integer "总重吨公里扣款"
    t.integer "综合指标扣款"
    t.integer "设备质量扣款"
    t.integer "盈亏结果扣款"
    t.integer "安全质量扣款"
    t.integer "安全质量考核中牌卡扣分"
    t.integer "安全质量考核中牌卡扣款"
    t.integer "工作质量扣款"
    t.integer "抽考扣款"
    t.integer "红牌中层扣款"
    t.integer "处分扣款"
    t.integer "其他扣款"
    t.integer "挂钩考核扣款"
    t.float "安全业绩扣分", limit: 24
    t.float "总重吨公里扣分", limit: 24
    t.float "综合指标扣分", limit: 24
    t.float "设备质量扣分", limit: 24
    t.float "盈亏结果扣分", limit: 24
    t.float "安全质量扣分", limit: 24
    t.float "工作质量扣分", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "company_relative_salers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "被考核科室"
    t.string "生产经营绩效考核得分"
    t.string "生产经营绩效考核扣分"
    t.string "生产经营绩效考核_综合指标扣分"
    t.string "生产经营绩效考核_设备质量扣分"
    t.string "安全质量考核得分"
    t.string "安全质量考核扣分"
    t.string "安全质量考核_牌卡检查问题考核扣分"
    t.string "工作质量考核_得分"
    t.string "工作质量考核_平均扣分"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "descend_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "year"
    t.integer "quarter"
    t.integer "sal_number"
    t.integer "application_id"
    t.string "descend_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "divide_level_wage_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "divide_head_name"
    t.string "head_name"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "divide_level_wages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.json "formula"
    t.string "name"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.integer "col10"
    t.integer "col11"
    t.integer "col12"
    t.integer "col13"
    t.integer "col14"
    t.integer "col15"
    t.integer "col16"
    t.integer "col17"
    t.integer "col18"
    t.integer "col19"
    t.integer "col20"
    t.integer "col21"
    t.integer "col22"
    t.integer "col23"
    t.integer "col24"
    t.integer "col25"
    t.integer "col26"
    t.integer "col27"
    t.integer "col28"
    t.integer "col29"
    t.integer "col30"
    t.integer "col31"
    t.integer "col32"
    t.integer "col33"
    t.integer "col34"
    t.integer "col35"
    t.integer "col36"
    t.integer "col37"
    t.integer "col38"
    t.integer "col39"
    t.integer "col40"
    t.integer "col41"
    t.integer "col42"
    t.integer "col43"
    t.integer "col44"
    t.integer "col45"
    t.integer "col46"
    t.integer "col47"
    t.integer "col48"
    t.integer "col49"
    t.integer "col50"
    t.integer "col51"
    t.integer "col52"
    t.integer "col53"
    t.integer "col54"
    t.integer "col55"
    t.integer "col56"
    t.integer "col57"
    t.integer "col58"
    t.integer "col59"
    t.integer "col60"
    t.integer "col61"
    t.integer "col62"
    t.integer "col63"
    t.integer "col64"
    t.integer "col65"
    t.integer "col66"
    t.integer "col67"
    t.integer "col68"
    t.integer "col69"
    t.integer "col70"
    t.integer "col71"
    t.integer "col72"
    t.integer "col73"
    t.integer "col74"
    t.integer "col75"
    t.integer "col76"
    t.integer "col77"
    t.integer "col78"
    t.integer "col79"
    t.integer "col80"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "djbonus", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.integer "month"
    t.integer "year"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.float "col4", limit: 24
    t.float "col5", limit: 24
    t.float "col6", limit: 24
    t.float "col7", limit: 24
    t.float "col8", limit: 24
    t.float "col9", limit: 24
    t.float "col10", limit: 24
    t.float "col11", limit: 24
    t.float "col12", limit: 24
    t.float "col13", limit: 24
    t.float "col14", limit: 24
    t.float "col15", limit: 24
    t.float "col16", limit: 24
    t.float "col17", limit: 24
    t.float "col18", limit: 24
    t.float "col19", limit: 24
    t.float "col20", limit: 24
    t.float "col21", limit: 24
    t.float "col22", limit: 24
    t.float "col23", limit: 24
    t.float "col24", limit: 24
    t.float "col25", limit: 24
    t.float "col26", limit: 24
    t.float "col27", limit: 24
    t.float "col28", limit: 24
    t.float "col29", limit: 24
    t.float "col30", limit: 24
    t.float "col31", limit: 24
    t.float "col32", limit: 24
    t.float "col33", limit: 24
    t.float "col34", limit: 24
    t.float "col35", limit: 24
    t.float "col36", limit: 24
    t.float "col37", limit: 24
    t.float "col38", limit: 24
    t.float "col39", limit: 24
    t.float "col40", limit: 24
    t.float "col41", limit: 24
    t.float "col42", limit: 24
    t.float "col43", limit: 24
    t.float "col44", limit: 24
    t.float "col45", limit: 24
    t.float "col46", limit: 24
    t.float "col47", limit: 24
    t.float "col48", limit: 24
    t.float "col49", limit: 24
    t.float "col50", limit: 24
    t.float "col51", limit: 24
    t.float "col52", limit: 24
    t.float "col53", limit: 24
    t.float "col54", limit: 24
    t.float "col55", limit: 24
    t.float "col56", limit: 24
    t.float "col57", limit: 24
    t.float "col58", limit: 24
    t.float "col59", limit: 24
    t.float "col60", limit: 24
    t.float "col61", limit: 24
    t.float "col62", limit: 24
    t.float "col63", limit: 24
    t.float "col64", limit: 24
    t.float "col65", limit: 24
    t.float "col66", limit: 24
    t.float "col67", limit: 24
    t.float "col68", limit: 24
    t.float "col69", limit: 24
    t.float "col70", limit: 24
    t.float "col71", limit: 24
    t.float "col72", limit: 24
    t.float "col73", limit: 24
    t.float "col74", limit: 24
    t.float "col75", limit: 24
    t.float "col76", limit: 24
    t.float "col77", limit: 24
    t.float "col78", limit: 24
    t.float "col79", limit: 24
    t.float "col80", limit: 24
    t.float "col81", limit: 24
    t.float "col82", limit: 24
    t.float "col83", limit: 24
    t.float "col84", limit: 24
    t.float "col85", limit: 24
    t.float "col86", limit: 24
    t.float "col87", limit: 24
    t.float "col88", limit: 24
    t.float "col89", limit: 24
    t.float "col90", limit: 24
    t.float "col91", limit: 24
    t.float "col92", limit: 24
    t.float "col93", limit: 24
    t.float "col94", limit: 24
    t.float "col95", limit: 24
    t.float "col96", limit: 24
    t.float "col97", limit: 24
    t.float "col98", limit: 24
    t.float "col99", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "djbonus_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "header"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "djwage_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "header"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "djwages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.integer "month"
    t.integer "year"
    t.string "col1"
    t.string "col2"
    t.float "col3", limit: 24
    t.float "col4", limit: 24
    t.float "col5", limit: 24
    t.float "col6", limit: 24
    t.float "col7", limit: 24
    t.float "col8", limit: 24
    t.float "col9", limit: 24
    t.float "col10", limit: 24
    t.float "col11", limit: 24
    t.float "col12", limit: 24
    t.float "col13", limit: 24
    t.float "col14", limit: 24
    t.float "col15", limit: 24
    t.float "col16", limit: 24
    t.float "col17", limit: 24
    t.float "col18", limit: 24
    t.float "col19", limit: 24
    t.float "col20", limit: 24
    t.float "col21", limit: 24
    t.float "col22", limit: 24
    t.float "col23", limit: 24
    t.float "col24", limit: 24
    t.float "col25", limit: 24
    t.float "col26", limit: 24
    t.float "col27", limit: 24
    t.float "col28", limit: 24
    t.float "col29", limit: 24
    t.float "col30", limit: 24
    t.float "col31", limit: 24
    t.float "col32", limit: 24
    t.float "col33", limit: 24
    t.float "col34", limit: 24
    t.float "col35", limit: 24
    t.float "col36", limit: 24
    t.float "col37", limit: 24
    t.float "col38", limit: 24
    t.float "col39", limit: 24
    t.float "col40", limit: 24
    t.float "col41", limit: 24
    t.float "col42", limit: 24
    t.float "col43", limit: 24
    t.float "col44", limit: 24
    t.float "col45", limit: 24
    t.float "col46", limit: 24
    t.float "col47", limit: 24
    t.float "col48", limit: 24
    t.float "col49", limit: 24
    t.float "col50", limit: 24
    t.float "col51", limit: 24
    t.float "col52", limit: 24
    t.float "col53", limit: 24
    t.float "col54", limit: 24
    t.float "col55", limit: 24
    t.float "col56", limit: 24
    t.float "col57", limit: 24
    t.float "col58", limit: 24
    t.float "col59", limit: 24
    t.float "col60", limit: 24
    t.float "col61", limit: 24
    t.float "col62", limit: 24
    t.float "col63", limit: 24
    t.float "col64", limit: 24
    t.float "col65", limit: 24
    t.float "col66", limit: 24
    t.float "col67", limit: 24
    t.float "col68", limit: 24
    t.float "col69", limit: 24
    t.float "col70", limit: 24
    t.float "col71", limit: 24
    t.float "col72", limit: 24
    t.float "col73", limit: 24
    t.float "col74", limit: 24
    t.float "col75", limit: 24
    t.float "col76", limit: 24
    t.float "col77", limit: 24
    t.float "col78", limit: 24
    t.float "col79", limit: 24
    t.float "col80", limit: 24
    t.float "col81", limit: 24
    t.float "col82", limit: 24
    t.float "col83", limit: 24
    t.float "col84", limit: 24
    t.float "col85", limit: 24
    t.float "col86", limit: 24
    t.float "col87", limit: 24
    t.float "col88", limit: 24
    t.float "col89", limit: 24
    t.float "col90", limit: 24
    t.float "col91", limit: 24
    t.float "col92", limit: 24
    t.float "col93", limit: 24
    t.float "col94", limit: 24
    t.float "col95", limit: 24
    t.float "col96", limit: 24
    t.float "col97", limit: 24
    t.float "col98", limit: 24
    t.float "col99", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emp_basic_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "员工基本信息表" do |t|
    t.string "sal_number", comment: "工资号"
    t.integer "workshop_id", comment: "车间"
    t.integer "group_id", comment: "班组"
    t.string "name", comment: "姓名"
    t.string "job_number", comment: "工号"
    t.integer "sex", limit: 1, default: 1, comment: "性别: 1-男， 2-女"
    t.string "identity_card_number", comment: "身份证号"
    t.integer "age", comment: "年龄"
    t.string "duty", comment: "职务"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employee_id", null: false
    t.index ["employee_id"], name: "index_emp_basic_infos_on_employee_id", unique: true
  end

  create_table "employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "sal_number", default: "", comment: "工资号"
    t.string "job_number", comment: "工号"
    t.string "record_number", comment: "档案号"
    t.string "workshop", comment: "车间"
    t.string "group", comment: "班组"
    t.string "name"
    t.string "sex"
    t.string "birth_date"
    t.integer "birth_year"
    t.integer "age"
    t.string "nation", comment: "民族"
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
    t.string "graduation_time", comment: "毕业时间"
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
    t.string "company_name", default: "北京供电段", comment: "单位名称"
    t.string "CJBZPX"
    t.string "family"
    t.integer "J01BF"
    t.string "duting", comment: "职务化"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "working_years", comment: "工作时长"
    t.integer "rali_years", comment: "入路时长"
    t.string "group_category", comment: "班组类别"
    t.string "job_foreman_category", comment: "班组长类别"
    t.string "job_foreman_duty", comment: "班组长职务"
    t.integer "group_id"
    t.integer "workshop_id"
    t.string "phone_number"
    t.string "avatar"
    t.boolean "duojing", default: false
    t.boolean "if_high_rails", default: false
    t.string "health"
    t.index ["sal_number"], name: "index_employees_on_sal_number", unique: true
  end

  create_table "examination_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "抽考返奖表" do |t|
    t.string "序号"
    t.string "工资编号"
    t.string "姓名"
    t.string "车间"
    t.string "金额"
    t.string "备注"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "examination_charges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "工资编号"
    t.string "车间"
    t.string "姓名"
    t.string "金额"
    t.string "签字"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "final_statistics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "year"
    t.integer "quarter"
    t.string "workshop"
    t.integer "number_of_workers"
    t.integer "five_star"
    t.integer "four_star"
    t.integer "three_star"
    t.integer "two_star"
    t.integer "one_star"
    t.float "total_amount", limit: 24, default: 0.0
    t.integer "team_leader_five_star"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.integer "workshop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: true
  end

  create_table "high_speed_rail_stuff_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "high_head_name"
    t.string "head_name"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "high_speed_rail_stuffs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.json "formula"
    t.string "name"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.integer "col10"
    t.integer "col11"
    t.integer "col12"
    t.integer "col13"
    t.integer "col14"
    t.integer "col15"
    t.integer "col16"
    t.integer "col17"
    t.integer "col18"
    t.integer "col19"
    t.integer "col20"
    t.integer "col21"
    t.integer "col22"
    t.integer "col23"
    t.integer "col24"
    t.integer "col25"
    t.integer "col26"
    t.integer "col27"
    t.integer "col28"
    t.integer "col29"
    t.integer "col30"
    t.integer "col31"
    t.integer "col32"
    t.integer "col33"
    t.integer "col34"
    t.integer "col35"
    t.integer "col36"
    t.integer "col37"
    t.integer "col38"
    t.integer "col39"
    t.integer "col40"
    t.integer "col41"
    t.integer "col42"
    t.integer "col43"
    t.integer "col44"
    t.integer "col45"
    t.integer "col46"
    t.integer "col47"
    t.integer "col48"
    t.integer "col49"
    t.integer "col50"
    t.integer "col51"
    t.integer "col52"
    t.integer "col53"
    t.integer "col54"
    t.integer "col55"
    t.integer "col56"
    t.integer "col57"
    t.integer "col58"
    t.integer "col59"
    t.integer "col60"
    t.integer "col61"
    t.integer "col62"
    t.integer "col63"
    t.integer "col64"
    t.integer "col65"
    t.integer "col66"
    t.integer "col67"
    t.integer "col68"
    t.integer "col69"
    t.integer "col70"
    t.integer "col71"
    t.integer "col72"
    t.integer "col73"
    t.integer "col74"
    t.integer "col75"
    t.integer "col76"
    t.integer "col77"
    t.integer "col78"
    t.integer "col79"
    t.integer "col80"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holiday_start_times", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "sal_number"
    t.string "name"
    t.string "vacation"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kuaizhao_contents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.json "formula"
    t.string "name"
    t.integer "year"
    t.integer "month"
    t.string "category"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.integer "col10"
    t.integer "col11"
    t.integer "col12"
    t.integer "col13"
    t.integer "col14"
    t.integer "col15"
    t.integer "col16"
    t.integer "col17"
    t.integer "col18"
    t.integer "col19"
    t.integer "col20"
    t.integer "col21"
    t.integer "col22"
    t.integer "col23"
    t.integer "col24"
    t.integer "col25"
    t.integer "col26"
    t.integer "col27"
    t.integer "col28"
    t.integer "col29"
    t.integer "col30"
    t.integer "col31"
    t.integer "col32"
    t.integer "col33"
    t.integer "col34"
    t.integer "col35"
    t.integer "col36"
    t.integer "col37"
    t.integer "col38"
    t.integer "col39"
    t.integer "col40"
    t.integer "col41"
    t.integer "col42"
    t.integer "col43"
    t.integer "col44"
    t.integer "col45"
    t.integer "col46"
    t.integer "col47"
    t.integer "col48"
    t.integer "col49"
    t.integer "col50"
    t.integer "col51"
    t.integer "col52"
    t.integer "col53"
    t.integer "col54"
    t.integer "col55"
    t.integer "col56"
    t.integer "col57"
    t.integer "col58"
    t.integer "col59"
    t.integer "col60"
    t.integer "col61"
    t.integer "col62"
    t.integer "col63"
    t.integer "col64"
    t.integer "col65"
    t.integer "col66"
    t.integer "col67"
    t.integer "col68"
    t.integer "col69"
    t.integer "col70"
    t.integer "col71"
    t.integer "col72"
    t.integer "col73"
    t.integer "col74"
    t.integer "col75"
    t.integer "col76"
    t.integer "col77"
    t.integer "col78"
    t.integer "col79"
    t.integer "col80"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kuaizhao_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "content_name"
    t.string "header_name"
    t.json "formula"
    t.string "category"
    t.integer "year"
    t.integer "month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leaving_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leaving_employees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.text "cause"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "leaving_type"
    t.integer "transfer_from_workshop"
    t.integer "transfer_from_group"
    t.integer "transfer_to_workshop"
    t.integer "transfer_to_group"
    t.integer "category_id"
  end

  create_table "main_driving_stuff_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "main_head_name"
    t.string "head_name"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "main_driving_stuffs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.json "formula"
    t.string "name"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.integer "col10"
    t.integer "col11"
    t.integer "col12"
    t.integer "col13"
    t.integer "col14"
    t.integer "col15"
    t.integer "col16"
    t.integer "col17"
    t.integer "col18"
    t.integer "col19"
    t.integer "col20"
    t.integer "col21"
    t.integer "col22"
    t.integer "col23"
    t.integer "col24"
    t.integer "col25"
    t.integer "col26"
    t.integer "col27"
    t.integer "col28"
    t.integer "col29"
    t.integer "col30"
    t.integer "col31"
    t.integer "col32"
    t.integer "col33"
    t.integer "col34"
    t.integer "col35"
    t.integer "col36"
    t.integer "col37"
    t.integer "col38"
    t.integer "col39"
    t.integer "col40"
    t.integer "col41"
    t.integer "col42"
    t.integer "col43"
    t.integer "col44"
    t.integer "col45"
    t.integer "col46"
    t.integer "col47"
    t.integer "col48"
    t.integer "col49"
    t.integer "col50"
    t.integer "col51"
    t.integer "col52"
    t.integer "col53"
    t.integer "col54"
    t.integer "col55"
    t.integer "col56"
    t.integer "col57"
    t.integer "col58"
    t.integer "col59"
    t.integer "col60"
    t.integer "col61"
    t.integer "col62"
    t.integer "col63"
    t.integer "col64"
    t.integer "col65"
    t.integer "col66"
    t.integer "col67"
    t.integer "col68"
    t.integer "col69"
    t.integer "col70"
    t.integer "col71"
    t.integer "col72"
    t.integer "col73"
    t.integer "col74"
    t.integer "col75"
    t.integer "col76"
    t.integer "col77"
    t.integer "col78"
    t.integer "col79"
    t.integer "col80"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "message_type"
    t.text "message"
    t.integer "user_id"
    t.boolean "have_read"
    t.datetime "remind_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "middle_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "中层干部返奖明细表" do |t|
    t.string "序号"
    t.string "姓名"
    t.string "工资号"
    t.string "部门"
    t.string "返奖金额"
    t.string "备注"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "other_award_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "排名奖励"
    t.string "防止安全隐患奖励"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.string "col4"
    t.string "col5"
    t.string "col6"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "col7"
    t.string "col8"
    t.string "col9"
    t.string "col10"
    t.string "col11"
    t.string "col12"
    t.string "col13"
    t.string "col14"
    t.string "col15"
    t.string "col16"
    t.string "col17"
    t.string "col18"
    t.string "col19"
    t.string "col20"
    t.string "col21"
    t.string "col22"
    t.string "col23"
    t.string "col24"
    t.string "col25"
    t.string "col26"
    t.string "col27"
    t.string "col28"
    t.string "col29"
    t.string "col30"
    t.string "col31"
    t.string "col32"
    t.string "col33"
    t.string "col34"
    t.string "col35"
    t.string "col36"
    t.string "col37"
    t.string "col38"
    t.string "col39"
    t.string "col40"
    t.string "col41"
    t.string "col42"
    t.string "col43"
    t.string "col44"
    t.string "col45"
    t.string "col46"
    t.string "col47"
    t.string "col48"
    t.string "col49"
    t.string "col50"
  end

  create_table "other_award_totals_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.string "col_name"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "other_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "工资号"
    t.string "姓名"
    t.string "车间"
    t.string "返奖金额"
    t.string "备注"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "people_changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "车间"
    t.string "班组"
    t.string "姓名"
    t.string "变动原因"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "production_stuff_wage_heads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "production_head_name"
    t.string "head_name"
    t.json "formula"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "production_stuff_wages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.json "formula"
    t.string "name"
    t.integer "col1"
    t.integer "col2"
    t.integer "col3"
    t.integer "col4"
    t.integer "col5"
    t.integer "col6"
    t.integer "col7"
    t.integer "col8"
    t.integer "col9"
    t.integer "col10"
    t.integer "col11"
    t.integer "col12"
    t.integer "col13"
    t.integer "col14"
    t.integer "col15"
    t.integer "col16"
    t.integer "col17"
    t.integer "col18"
    t.integer "col19"
    t.integer "col20"
    t.integer "col21"
    t.integer "col22"
    t.integer "col23"
    t.integer "col24"
    t.integer "col25"
    t.integer "col26"
    t.integer "col27"
    t.integer "col28"
    t.integer "col29"
    t.integer "col30"
    t.integer "col31"
    t.integer "col32"
    t.integer "col33"
    t.integer "col34"
    t.integer "col35"
    t.integer "col36"
    t.integer "col37"
    t.integer "col38"
    t.integer "col39"
    t.integer "col40"
    t.integer "col41"
    t.integer "col42"
    t.integer "col43"
    t.integer "col44"
    t.integer "col45"
    t.integer "col46"
    t.integer "col47"
    t.integer "col48"
    t.integer "col49"
    t.integer "col50"
    t.integer "col51"
    t.integer "col52"
    t.integer "col53"
    t.integer "col54"
    t.integer "col55"
    t.integer "col56"
    t.integer "col57"
    t.integer "col58"
    t.integer "col59"
    t.integer "col60"
    t.integer "col61"
    t.integer "col62"
    t.integer "col63"
    t.integer "col64"
    t.integer "col65"
    t.integer "col66"
    t.integer "col67"
    t.integer "col68"
    t.integer "col69"
    t.integer "col70"
    t.integer "col71"
    t.integer "col72"
    t.integer "col73"
    t.integer "col74"
    t.integer "col75"
    t.integer "col76"
    t.integer "col77"
    t.integer "col78"
    t.integer "col79"
    t.integer "col80"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rectification_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "整改返奖合计"
    t.string "牌卡返奖"
    t.string "中层返奖"
    t.string "班组长返奖"
    t.string "抽考返奖"
    t.string "其他返奖"
    t.string "备注"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "red_middle_charges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "姓名"
    t.string "工资号"
    t.string "部门"
    t.string "核减金额"
    t.string "备注"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "relative_salers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", comment: "工效挂钩工资明细表（科室车间上传）" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "部门班组"
    t.string "工资号"
    t.string "姓名"
    t.string "系数"
    t.string "挂钩工资"
    t.string "安全质量"
    t.string "工作质量"
    t.string "一体化"
    t.string "兼职兼岗"
    t.string "其他"
    t.string "应发"
    t.string "考核扣款"
    t.string "合计"
    t.string "备注"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
  end

  create_table "relative_salers_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "挂钩工资"
    t.string "安全质量"
    t.string "工作质量"
    t.string "行车"
    t.string "整改返奖"
    t.string "一体化"
    t.string "兼职兼岗"
    t.string "考核扣款"
    t.string "其他"
    t.string "应发"
    t.string "小计"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "translate_role"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "score_weights", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.float "theory_score", limit: 24, default: 0.0
    t.float "practical_score", limit: 24, default: 0.0
    t.float "work_performance", limit: 24, default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_award_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "标准化合计"
    t.string "标准化科室车间"
    t.string "标准化班组"
    t.string "标杆优秀达标车间奖励"
    t.string "科室车间备份"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "班组名称"
    t.string "评定等级"
    t.string "奖励标准"
    t.string "人数"
    t.string "奖励金额"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "star_applications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "star_info_id"
    t.integer "up_down_star"
    t.string "applicant"
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "treatment_state"
  end

  create_table "star_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "科室车间"
    t.string "序号"
    t.string "发放合计"
    t.string "总人数"
    t.string "五星岗"
    t.string "四星岗"
    t.string "三星岗"
    t.string "二星岗"
    t.string "一星岗"
    t.string "五星人数"
    t.string "四星人数"
    t.string "三星人数"
    t.string "二星人数"
    t.string "一星人数"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "star_confirm_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "year"
    t.integer "quarter"
    t.boolean "status", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "star_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "basic_score_id"
    t.integer "year"
    t.integer "quarter"
    t.string "workshop"
    t.string "group"
    t.string "name"
    t.string "sal_number"
    t.string "duty"
    t.float "final_score", limit: 24, default: 0.0
    t.string "star"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "team_leader", default: false
  end

  create_table "star_ranges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "name"
    t.string "f_type"
    t.float "value", limit: 24, default: 0.0
    t.float "money", limit: 24, default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teamleader_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "车间"
    t.string "班组"
    t.string "工资号"
    t.string "姓名"
    t.string "性别"
    t.string "金额"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "upload_year"
    t.string "upload_month"
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
    t.integer "workshop_id"
    t.integer "group_id"
    t.integer "role_id"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vacation_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "vacation_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vacation_shortening", comment: "假期简称"
    t.string "vacation_code", comment: "假期代码"
  end

  create_table "wage_headers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "header"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "formula"
  end

  create_table "wages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "employee_id"
    t.integer "month"
    t.integer "year"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.string "col4"
    t.string "col5"
    t.string "col6"
    t.string "col7"
    t.string "col8"
    t.string "col9"
    t.string "col10"
    t.string "col11"
    t.string "col12"
    t.float "col13", limit: 24
    t.float "col14", limit: 24
    t.float "col15", limit: 24
    t.float "col16", limit: 24
    t.float "col17", limit: 24
    t.float "col18", limit: 24
    t.float "col19", limit: 24
    t.float "col20", limit: 24
    t.float "col21", limit: 24
    t.float "col22", limit: 24
    t.float "col23", limit: 24
    t.float "col24", limit: 24
    t.float "col25", limit: 24
    t.float "col26", limit: 24
    t.float "col27", limit: 24
    t.float "col28", limit: 24
    t.float "col29", limit: 24
    t.float "col30", limit: 24
    t.float "col31", limit: 24
    t.float "col32", limit: 24
    t.float "col33", limit: 24
    t.float "col34", limit: 24
    t.float "col35", limit: 24
    t.float "col36", limit: 24
    t.float "col37", limit: 24
    t.float "col38", limit: 24
    t.float "col39", limit: 24
    t.float "col40", limit: 24
    t.float "col41", limit: 24
    t.float "col42", limit: 24
    t.float "col43", limit: 24
    t.float "col44", limit: 24
    t.float "col45", limit: 24
    t.float "col46", limit: 24
    t.float "col47", limit: 24
    t.float "col48", limit: 24
    t.float "col49", limit: 24
    t.float "col50", limit: 24
    t.float "col51", limit: 24
    t.float "col52", limit: 24
    t.float "col53", limit: 24
    t.float "col54", limit: 24
    t.float "col55", limit: 24
    t.float "col56", limit: 24
    t.float "col57", limit: 24
    t.float "col58", limit: 24
    t.float "col59", limit: 24
    t.float "col60", limit: 24
    t.float "col61", limit: 24
    t.float "col62", limit: 24
    t.float "col63", limit: 24
    t.float "col64", limit: 24
    t.float "col65", limit: 24
    t.float "col66", limit: 24
    t.float "col67", limit: 24
    t.float "col68", limit: 24
    t.float "col69", limit: 24
    t.float "col70", limit: 24
    t.float "col71", limit: 24
    t.float "col72", limit: 24
    t.float "col73", limit: 24
    t.float "col74", limit: 24
    t.float "col75", limit: 24
    t.float "col76", limit: 24
    t.float "col77", limit: 24
    t.float "col78", limit: 24
    t.float "col79", limit: 24
    t.float "col80", limit: 24
    t.float "col81", limit: 24
    t.float "col82", limit: 24
    t.float "col83", limit: 24
    t.float "col84", limit: 24
    t.float "col85", limit: 24
    t.float "col86", limit: 24
    t.float "col87", limit: 24
    t.float "col88", limit: 24
    t.float "col89", limit: 24
    t.float "col90", limit: 24
    t.float "col91", limit: 24
    t.float "col92", limit: 24
    t.float "col93", limit: 24
    t.float "col94", limit: 24
    t.float "col95", limit: 24
    t.float "col96", limit: 24
    t.float "col97", limit: 24
    t.float "col98", limit: 24
    t.float "col99", limit: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "col100", limit: 24
    t.float "col101", limit: 24
    t.float "col102", limit: 24
    t.float "col103", limit: 24
    t.float "col104", limit: 24
    t.float "col105", limit: 24
    t.float "col106", limit: 24
    t.float "col107", limit: 24
    t.float "col108", limit: 24
    t.float "col109", limit: 24
    t.float "col110", limit: 24
    t.float "col111", limit: 24
    t.float "col112", limit: 24
    t.float "col113", limit: 24
    t.float "col114", limit: 24
    t.float "col115", limit: 24
    t.float "col116", limit: 24
    t.float "col117", limit: 24
    t.float "col118", limit: 24
    t.float "col119", limit: 24
    t.float "col120", limit: 24
    t.float "col121", limit: 24
    t.float "col122", limit: 24
    t.float "col123", limit: 24
    t.float "col124", limit: 24
    t.float "col125", limit: 24
    t.float "col126", limit: 24
    t.float "col127", limit: 24
    t.float "col128", limit: 24
    t.float "col129", limit: 24
    t.float "col130", limit: 24
    t.float "col131", limit: 24
    t.float "col132", limit: 24
    t.float "col133", limit: 24
    t.float "col134", limit: 24
    t.float "col135", limit: 24
    t.float "col136", limit: 24
    t.float "col137", limit: 24
    t.float "col138", limit: 24
    t.float "col139", limit: 24
    t.float "col140", limit: 24
    t.float "col141", limit: 24
    t.float "col142", limit: 24
    t.float "col143", limit: 24
    t.float "col144", limit: 24
    t.float "col145", limit: 24
    t.float "col146", limit: 24
    t.float "col147", limit: 24
    t.float "col148", limit: 24
    t.float "col149", limit: 24
    t.float "col150", limit: 24
  end

  create_table "workshop_relative_salers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "姓名"
    t.string "工资号"
    t.integer "挂钩工资"
    t.integer "安全质量"
    t.integer "工作质量"
    t.integer "行车"
    t.integer "整改返奖"
    t.integer "一体化"
    t.integer "兼职兼岗"
    t.integer "考核扣款"
    t.integer "其他"
    t.integer "应发"
    t.integer "小计"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workshop_single_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "班组"
    t.string "工资号"
    t.string "姓名"
    t.string "单项奖"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.string "col1"
    t.string "col2"
    t.string "col3"
    t.string "col4"
    t.string "col5"
    t.string "col6"
    t.string "col7"
    t.string "col8"
    t.string "col9"
    t.string "col10"
    t.string "col11"
    t.string "col12"
    t.string "col13"
    t.string "col14"
    t.string "col15"
    t.string "col16"
    t.string "col17"
    t.string "col18"
    t.string "col19"
    t.string "col20"
    t.string "col21"
    t.string "col22"
    t.string "col23"
    t.string "col24"
    t.string "col25"
    t.string "col26"
    t.string "col27"
    t.string "col28"
    t.string "col29"
    t.string "col30"
    t.string "col31"
    t.string "col32"
    t.string "col33"
    t.string "col34"
    t.string "col35"
    t.string "col36"
    t.string "col37"
    t.string "col38"
    t.string "col39"
    t.string "col40"
    t.string "col41"
    t.string "col42"
    t.string "col43"
    t.string "col44"
    t.string "col45"
    t.string "col46"
    t.string "col47"
    t.string "col48"
    t.string "col49"
    t.string "col50"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workshop_standart_star_awards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "序号"
    t.string "科室车间"
    t.string "班组"
    t.string "工资号"
    t.string "姓名"
    t.string "标准化"
    t.string "星级岗"
    t.string "备注"
    t.string "upload_year"
    t.string "upload_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workshops", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: true
  end

end
