class EmployeesController < ApplicationController

  def index
    @employees = Employee.page(params[:page]).per(20)
  end

  def new
  	
  end

  def edit
  	
  end

  def show
  	
  end

  def search
    @employees = Employee.search(params[:q]).page(params[:page]).records
    render action: "index"
  end

  def import
    Employee.import(params[:file])
    redirect_to employees_path
  end

  def organization_structure
  	
  end

### 统计分析页面的图表数据配置---开始
  def statistical_analysis
   ## 年龄分析-饼图数据配置---开始
    # 把各个年龄段的人数捞出，赋值给对应的实例变量
  	@age_25_below = Employee.where(age: 0..25).count
    @age_25 = Employee.where(age: 25..30).count
    @age_30 = Employee.where(age: 30..35).count
    @age_35 = Employee.where(age: 35..40).count
    @age_40 = Employee.where(age: 40..45).count
    @age_45 = Employee.where(age: 45..50).count
    @age_50 = Employee.where(age: 50..55).count
    @age_55 = Employee.where(age: 55..60).count    
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量
    gon.twenty_five_below = @age_25_below
    gon.twenty_five = @age_25
    gon.thirty =  @age_30
    gon.thirty_five =  @age_35
    gon.forty =  @age_40
    gon.forty_five = @age_45
    gon.fifty = @age_50
    gon.fifty_five = @age_55   
  ## 年龄分析-饼图数据配置---结束

  ## 学历分析-饼图数据配置---开始
    # 把各个学历的人数捞出，赋值给对应的实例变量
    @junior_high_school_below = Employee.where(education_background: ["小学", "初中"]).count
    @senior_high_school = Employee.where(education_background: "高中").count
    @technical_school = Employee.where(education_background: "技校").count
    @secondary_school = Employee.where(education_background: "中专").count
    @university_specialties = Employee.where(education_background: "大学专科").count
    @undergraduate = Employee.where(education_background: "大学本科").count
    @postgraduate = Employee.where(education_background: "研究生").count
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量
    gon.junior_high_school_below = @junior_high_school_below
    gon.senior_high_school = @senior_high_school
    gon.technical_school =  @technical_school
    gon.secondary_school =  @secondary_school
    gon.university_specialties =  @university_specialties
    gon.undergraduate = @undergraduate
    gon.postgraduate = @postgraduate
  ## 学历分析-饼图数据配置---结束

  ## 年龄分析-柱状图数据配置---开始
    
    #捞出所有的车间，赋值给实例变量
    @workshops = Employee.pluck("workshop").uniq
    #生成每个年龄段的【车间-人数】hash---开始
    #定义每个年龄段各个车间的hash（包括在循环里使用的和最后存入的）
    loop_hash_25_below = {}
    hash_25_below = {}
    loop_hash_25 = {}
    hash_25 = {}
    loop_hash_30 = {}
    hash_30 = {}
    loop_hash_35 = {}
    hash_35 = {}
    loop_hash_40 = {}
    hash_40 = {}
    loop_hash_45 = {}
    hash_45 = {}
    loop_hash_50 = {}
    hash_50 = {}
    loop_hash_55 = {}
    hash_55 = {}
    #使用循环把车间和人数存成hash
    @workshops.each do |i|
      a = Employee.where(workshop: i, age: 0..25).count
      loop_hash_25_below = {i => a}
      hash_25_below[i] = loop_hash_25_below[i]

      b = Employee.where(workshop: i, age: 25..30).count
      loop_hash_25 = {i => b}
      hash_25[i] = loop_hash_25_below[i]

      c = Employee.where(workshop: i, age: 30..35).count
      loop_hash_30 = {i => c}
      hash_30[i] = loop_hash_30[i]

      d = Employee.where(workshop: i, age: 35..40).count
      loop_hash_35 = {i => d}
      hash_35[i] = loop_hash_35[i]

      e = Employee.where(workshop: i, age: 40..45).count
      loop_hash_40 = {i => e}
      hash_40[i] = loop_hash_40[i]

      f = Employee.where(workshop: i, age: 45..50).count
      loop_hash_45 = {i => f}
      hash_45[i] = loop_hash_45[i]

      g = Employee.where(workshop: i, age: 50..55).count
      loop_hash_50 = {i => g}
      hash_50[i] = loop_hash_50[i]

      h = Employee.where(workshop: i, age: 55..60).count
      loop_hash_55 = {i => h}
      hash_55[i] = loop_hash_55[i]

    end
    #生成每个年龄段的【车间-人数】hash---结束

    # 使用'gon'这个gem的方法，将数据赋值给对应的变量
    gon.bar_twenty_five_below_k = hash_25_below.keys
    gon.bar_twenty_five_below_v = hash_25_below.values
    gon.bar_twenty_five_v = hash_25.values
    gon.bar_thirty_v = hash_30.values
    gon.bar_thirty_five_v = hash_35.values
    gon.bar_forty_v = hash_40.values
    gon.bar_forty_five_v = hash_45.values
    gon.bar_fifty_v = hash_50.values
    gon.bar_fifty_five_v = hash_55.values


  ## 年龄分析-柱状图数据配置---结束

  end
### 统计分析页面的图表数据配置---结束

### 年龄分析饼图-表格详细数据配置
  def age_analysis_data
  ## 通过饼图每个扇形url里附带的参数来判断给出的数据
    case params[:age]
    when "25岁以下"
      @age_employees = Employee.where(age: 0..25)
    when "25"
      @age_employees = Employee.where(age: 25..30)
    when "30"
      @age_employees = Employee.where(age: 30..35)
    when "35"
      @age_employees = Employee.where(age: 35..40)
    when "40"
      @age_employees = Employee.where(age: 40..45)
    when "45"
      @age_employees = Employee.where(age: 45..50)
    when "50"
      @age_employees = Employee.where(age: 50..55)
    when "55"
      @age_employees = Employee.where(age: 55..60)
    end
  end


### 年龄分析饼图-表格详细数据配置
  def education_background_analysis_data
  ## 通过饼图每个扇形url里附带的参数来判断给出的数据
    case params[:education]
    when "初中及以下"
      @education_employees = Employee.where(education_background: ["小学", "初中"])
    when "高中"
      @education_employees = Employee.where(education_background: "高中")
    when "技校"
      @education_employees = Employee.where(education_background: "技校")
    when "中专"
      @education_employees = Employee.where(education_background: "中专")
    when "大学专科"
      @education_employees = Employee.where(education_background: "大学专科")
    when "大学本科"
      @education_employees = Employee.where(education_background: "大学本科")
    when "研究称"
      @education_employees = Employee.where(education_background: "研究生")
    end
  end


end
