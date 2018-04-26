class EmployeesController < ApplicationController
  layout 'home'
  def index
    @employees = Employee.page(params[:page]).per(50)
    @export_employees = Employee.order("id ASC")
    respond_to do |format|
      format.html
      format.csv { send_data @employees.to_csv }
      format.xls
    end
  end

  def new
  end

  def edit
  end

  def show
    @employee = Employee.find(params[:id])
  end

  def import_table
    Employee.import_table(params[:file])
    redirect_to employees_path
  end

  def search
    @employees = Employee.search(params[:q]).page(params[:page]).records
    render action: "index"
  end


  def update_employee_info
    @employees = Employee.all
    @employees.each do |employee|
      employee.sal_number = '41' + employee.job_number
      employee.birth_year = employee.birth_date[0..3]
      employee.age = Time.now.year - employee.birth_year.to_i
      working_years_transfer = (Time.now - employee.working_time.to_datetime)/60/60/24/365
      rali_years_transfer = (Time.now - employee.railway_time.to_datetime)/60/60/24/365
      employee.working_years = working_years_transfer.to_i
      employee.rali_years = rali_years_transfer.to_i
      employee.save!
    end
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
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
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
    @junior_high_school = Employee.where(education_background: ["初中"]).count
    @primary_school = Employee.where(education_background: ["小学"]).count
    @senior_high_school = Employee.where(education_background: "高中").count
    @technical_school = Employee.where(education_background: "技校").count
    @secondary_school = Employee.where(education_background: "中专").count
    @university_specialties = Employee.where(education_background: "大学专科").count
    @undergraduate = Employee.where(education_background: "大学本科").count
    @postgraduate = Employee.where(education_background: "研究生").count
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
    gon.junior_high_school = @junior_high_school_below
    gon.senior_high_school = @senior_high_school
    gon.technical_school =  @technical_school
    gon.secondary_school =  @secondary_school
    gon.university_specialties =  @university_specialties
    gon.undergraduate = @undergraduate
    gon.postgraduate = @postgraduate
    gon.primary_school = @primary_school
  ## 学历分析-饼图数据配置---结束

  ## 年龄分析-条形图数据配置---开始
    #捞出所有的车间，赋值给实例变量
    @workshops = Employee.pluck("workshop").uniq
    @educations = Employee.pluck("education_background").uniq
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

    loop_hash_junior_high_school = {}
    hash_junior_high_school = {}
    loop_hash_primary_school = {}
    hash_primary_school = {}
    loop_hash_senior_high_school = {}
    hash_senior_high_school = {}
    loop_hash_technical_school = {}
    hash_technical_school = {}
    loop_hash_secondary_school = {}
    hash_secondary_school = {}
    loop_hash_university_specialties = {}
    hash_university_specialties = {}
    loop_hash_undergraduate = {}
    hash_undergraduate = {}
    loop_hash_postgraduate = {}
    hash_postgraduate = {}
    #使用循环把车间和人数存成hash
    @workshops.each do |i|
      a1 = Employee.where(workshop: i, age: 0...25).count
      aa1 = Employee.where(workshop: i, education_background: "初中").count
      a2 = Employee.where(workshop: i).count
      a = (a1.to_f)/(a2.to_f)
      aa = (aa1.to_f)/(a2.to_f)
      loop_hash_25_below = {i => a}
      loop_hash_junior_high_school = {i => aa}
      hash_25_below[i] = loop_hash_25_below[i]
      hash_junior_high_school[i] = loop_hash_junior_high_school[i]

      b1 = Employee.where(workshop: i, age: 25...30).count
      ab1 = Employee.where(workshop: i, education_background: "小学").count
      b2 = Employee.where(workshop: i).count
      b = (b1.to_f)/(b2.to_f)
      ab = (ab1.to_f)/(b2.to_f)
      loop_hash_25 = {i => b}
      loop_hash_primary_school = {i => ab}
      hash_25[i] = loop_hash_25[i]
      hash_primary_school[i] = loop_hash_primary_school[i]

      c1 = Employee.where(workshop: i, age: 30...35).count
      ac1 = Employee.where(workshop: i, education_background: "高中").count
      c2 = Employee.where(workshop: i).count
      c = (c1.to_f)/(c2.to_f)
      ac = (ac1.to_f)/(c2.to_f)
      loop_hash_30 = {i => c}
      loop_hash_senior_high_school = {i => ac}
      hash_30[i] = loop_hash_30[i]
      hash_senior_high_school[i] = loop_hash_senior_high_school[i]

      d1 = Employee.where(workshop: i, age: 35...40).count
      ad1 = Employee.where(workshop: i, education_background: "技校").count
      d2 = Employee.where(workshop: i).count
      d = (d1.to_f)/(d2.to_f)
      ad = (ad1.to_f)/(d2.to_f)
      loop_hash_35 = {i => d}
      loop_hash_technical_school = {i => ad}
      hash_35[i] = loop_hash_35[i]
      hash_technical_school[i] = loop_hash_technical_school[i]

      e1 = Employee.where(workshop: i, age: 40...45).count
      ae1 = Employee.where(workshop: i, education_background: "中专").count
      e2 = Employee.where(workshop: i).count
      e = (e1.to_f)/(e2.to_f)
      ae = (ae1.to_f)/(e2.to_f)
      loop_hash_40 = {i => e}
      loop_hash_secondary_school = {i => ae}
      hash_40[i] = loop_hash_40[i]
      hash_secondary_school[i] = loop_hash_secondary_school[i]

      f1 = Employee.where(workshop: i, age: 45...50).count
      af1 = Employee.where(workshop: i, education_background: "大学专科").count
      f2 = Employee.where(workshop: i).count
      f = (f1.to_f)/(f2.to_f)
      af = (af1.to_f)/(f2.to_f)
      loop_hash_45 = {i => f}
      loop_hash_university_specialties = {i => af}
      hash_45[i] = loop_hash_45[i]
      hash_university_specialties[i] = loop_hash_university_specialties[i]

      g1 = Employee.where(workshop: i, age: 50...55).count
      ag1 = Employee.where(workshop: i, education_background: "大学本科").count
      g2 = Employee.where(workshop: i).count
      g = (g1.to_f)/(g2.to_f)
      ag = (ag1.to_f)/(g2.to_f)
      loop_hash_50 = {i => g}
      loop_hash_undergraduate = {i => ag}
      hash_50[i] = loop_hash_50[i]
      hash_undergraduate[i] = loop_hash_undergraduate[i]

      h1 = Employee.where(workshop: i, age: 55..70).count
      ah1 = Employee.where(workshop: i, education_background: "研究生").count
      h2 = Employee.where(workshop: i).count
      h = (h1.to_f)/(h2.to_f)
      ah = (ah1.to_f)/(h2.to_f)
      loop_hash_55 = {i => h}
      loop_hash_postgraduate = {i => ah}
      hash_55[i] = loop_hash_55[i]
      hash_postgraduate[i] = loop_hash_postgraduate[i]
    end
    #生成每个年龄段的【车间-人数】hash---结束

    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
    gon.bar_workshop = hash_25_below.keys
    gon.bar_twenty_five_below = hash_25_below.values
    gon.bar_twenty_five = hash_25.values
    gon.bar_thirty = hash_30.values
    gon.bar_thirty_five = hash_35.values
    gon.bar_forty = hash_40.values
    gon.bar_forty_five = hash_45.values
    gon.bar_fifty = hash_50.values
    gon.bar_fifty_five = hash_55.values
  ## 年龄分析-条形图数据配置---结束
    gon.bar_junior_high_school = hash_junior_high_school.values
    gon.bar_primary_school = hash_primary_school.values
    gon.bar_senior_high_school = hash_senior_high_school.values
    gon.bar_technical_school = hash_technical_school.values
    gon.bar_secondary_school = hash_secondary_school.values
    gon.bar_university_specialties = hash_university_specialties.values
    gon.bar_undergraduate = hash_undergraduate.values
    gon.bar_postgraduate = hash_postgraduate.values
    render layout: 'application'
  end
### 统计分析页面的图表数据配置---结束


### 年龄分析饼图-表格详细数据配置
  def age_analysis_data
  ## 通过饼图url里附带的参数来判断给出的数据
    case params[:age]
    when "25岁以下"
      @age_employees = Employee.where(age: 0...25)
    when "25-30岁"
      @age_employees = Employee.where(age: 25...30)
    when "30-35岁"
      @age_employees = Employee.where(age: 30...35)
    when "35-40岁"
      @age_employees = Employee.where(age: 35...40)
    when "40-45岁"
      @age_employees = Employee.where(age: 40...45)
    when "45-50岁"
      @age_employees = Employee.where(age: 45...50)
    when "50-55岁"
      @age_employees = Employee.where(age: 50...55)
    when "55岁以上"
      @age_employees = Employee.where(age: 55..60)
    end
  end


### 学历分析饼图-表格详细数据配置
  def education_background_analysis_data
  ## 通过饼图url里附带的参数来判断给出的数据
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

### 年龄分析条形图-表格详细数据配置
  def age_analysis_data_bar
    ## 通过条形图url里附带的参数来判断给出的数据
    case params[:age]
    when "25岁以下"
      ## 参数workshop和数据库存储的一致，可直接用来搜索，而年龄需使用区间搜索，因此使用条件判断
      @age_employees = Employee.where(workshop: params[:workshop], age: 0...25)
    when "25-30岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 25...30)
    when "30-35岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 30...35)
    when "35-40岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 35...40)
    when "40-45岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 40...45)
    when "45-50岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 45...50)
    when "50-55岁"
      @age_employees = Employee.where(workshop: params[:workshop], age: 50...55)
    when "55岁以上"
      @age_employees = Employee.where(workshop: params[:workshop], age: 55..60)
    end
  end

  def education_background_analysis_data_bar
    @education_employees = Employee.where(workshop: params[:workshop], education_background: params[:education])
  end

  def organization_structure
    @workshops = Employee.pluck("workshop").uniq
    if params[:workshop].present?
      @employees = Employee.where(workshop: params[:workshop])
    elsif params[:group].present?
      @employees = Employee.where(group: params[:group])
    else
      @employees = Employee.all
    end
  end


end
