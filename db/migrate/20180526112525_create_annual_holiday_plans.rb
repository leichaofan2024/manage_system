class CreateAnnualHolidayPlans < ActiveRecord::Migration[5.1]
  def change
    create_table :annual_holiday_plans do |t|
      t.integer :workshop_id
      t.integer :work_type,                     comment: "工种"
      t.integer :last_year_people_number,       comment: "上年末单位人数"
      t.integer :this_year_people_number,       comment: "今年休年休假人数"
      t.integer :five_days,                     comment: "休5天人数"
      t.integer :ten_days,                      comment: "休10天人数"
      t.integer :fifteen_days,                  comment: "休15天人数"
      t.integer :holiday_days,                  comment: "应休假天数"
      t.integer :January_plan_number,           comment: "一月份安排人数"
      t.integer :January_plan_days,             comment: "一月份休假天数"
      t.integer :February_plan_number,          comment: "二月份安排人数"
      t.integer :February_plan_days,            comment: "二月份休假天数"
      t.integer :March_plan_number,             comment: "三月份安排人数"
      t.integer :March_plan_days,               comment: "三月份休假天数"
      t.integer :April_plan_number,             comment: "四月份安排人数"
      t.integer :April_plan_days,               comment: "四月份休假天数"
      t.integer :May_plan_number,               comment: "五月份安排人数"
      t.integer :May_plan_days,                 comment: "五月份休假天数"
      t.integer :June_plan_number,              comment: "六月份安排人数"
      t.integer :June_plan_days,                comment: "六月份休假天数"
      t.integer :July_plan_number,              comment: "七月份安排人数"
      t.integer :July_plan_days,                comment: "七月份休假天数"
      t.integer :August_plan_number,            comment: "八月份安排人数"
      t.integer :August_plan_days,              comment: "八月份休假天数"
      t.integer :September_plan_number,         comment: "九月份安排人数"
      t.integer :September_plan_days,           comment: "九月份休假天数"
      t.integer :October_plan_number,           comment: "十月份安排人数"
      t.integer :October_plan_days,             comment: "十月份休假天数"
      t.integer :November_plan_number,          comment: "十一月份安排人数"
      t.integer :November_plan_days,            comment: "十一月份休假天数"
      t.integer :December_plan_number,          comment: "十二月份安排人数"
      t.integer :December_plan_days,            comment: "十二月份休假天数"
      t.timestamps
    end
  end
end
