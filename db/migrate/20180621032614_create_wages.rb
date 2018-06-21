class CreateWages < ActiveRecord::Migration[5.1]
  def change
    create_table :wages do |t|
      t.integer :employee_id
      t.string :bank_account, comment: "银行账号"
      t.string :housing_accumulation_fund_account, comment: "公积金号"
      t.string :account_category, comment: "账号类别"
      t.integer :skill, comment: "技能"
      t.integer :post, comment: "岗位"
      t.integer :post_safety_assessment, comment: "岗安考核"
      t.integer :working_years, comment: "工龄"
      t.integer :overtime_days, comment: "加班天数"
      t.integer :overtime_pay, comment: "加班费"
      t.integer :daytime_night_shift, comment: "日勤夜班"
      t.integer :night_shift_by_turn, comment: "轮流夜班"
      t.integer :night_shift_pay, comment: "夜班费"
      t.integer :living_allowance, comment: "生活补贴"
      t.integer :increase_performance, comment: "增效"
      t.integer :transportation_fee, comment: "交通费"
      t.integer :hygiene_fee, comment: "卫生费"
      t.integer :single_subsidy, comment: "独补"
      t.integer :child_care_subsidy, comment: "托补"
      t.integer :milk_subsidy, comment: "奶补"
      t.integer :house_subsidy, comment: "房补"
      t.integer :survivor_subsidy, comment: "遗属补贴"
      t.integer :huimin_subsidy, comment: "回民补贴"
      t.integer :cadre_subsidy, comment: "干部补贴"
      t.integer :worker_subsidy, comment: "工人补贴"
      t.integer :book_fee, comment: "书报费"
      t.integer :bonus, comment: "奖金"
      t.integer :increased_salary, comment: "增资"
      t.integer :first_line_allowance, comment: "一线津贴"
      t.integer :special_salary, comment: "特种工资"
      t.integer :work_injury_treatment, comment: "工伤待遇"
      t.integer :five_seven_subsidy, comment: "五七补"
      t.integer :minimum_wage, comment: "最低工资"
      t.integer :taBu1, comment: "它补1"
      t.integer :taBu2, comment: "它补2"
      t.integer :high_temperature_allowance, comment: "高温津贴"
      t.integer :wage_payable, comment: "应发工资"
      t.integer :real_wage, comment: "实发工资"
      t.integer :summary1, comment: "汇总1"
      t.integer :summary2, comment: "汇总2"
      t.integer :summary3, comment: "汇总3"
      t.integer :withholding_annuity, comment: "扣年金"
      t.integer :withholding_fee, comment: "扣会费"
      t.integer :withholding_housing_accumulation_fund, comment: "扣公积金"
      t.integer :withholding_pension, comment: "扣养老金"
      t.integer :withholding_unemployment_compensation, comment: "扣失业金"
      t.integer :withholding_medical_insurance, comment: "扣医保"
      t.integer :tax_calculation, comment: "税款计算"
      t.integer :withholding_bundling, comment: "扣捆绑"
      t.integer :total_room_charge, comment: "房费合计"
      t.integer :beijing_room_charge, comment: "北京房费"
      t.integer :fengtai_room_charge, comment: "丰台房费"
      t.integer :jingxi_room_charge, comment: "京西房费"
      t.integer :chengde_room_charge, comment: "承德房费"
      t.integer :huaibei_room_charge, comment: "怀北房费"
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.integer :
      t.timestamps
    end
  end
end
