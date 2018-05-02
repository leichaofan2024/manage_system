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
    @employee = Employee.find(params[:id])
  end

  def update
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

  ## 工龄分析-饼图数据配置---开始
    # 把各个工龄段的人数捞出，赋值给对应的实例变量
    @working_years_5_below = Employee.where(working_years: 0...5).count
    @working_years_5 = Employee.where(working_years: 5...10).count
    @working_years_10 = Employee.where(working_years: 10...15).count
    @working_years_15 = Employee.where(working_years: 15...20).count
    @working_years_20 = Employee.where(working_years: 20...25).count
    @working_years_25 = Employee.where(working_years: 25...30).count
    @working_years_30 = Employee.where(working_years: 30...35).count
    @working_years_35 = Employee.where(working_years: 35...40).count
    @working_years_40_up = Employee.where(working_years: 40..100).count
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
    gon.working_years_5_below = @working_years_5_below
    gon.working_years_5 = @working_years_5
    gon.working_years_10 = @working_years_10
    gon.working_years_15 = @working_years_15
    gon.working_years_20 = @working_years_20
    gon.working_years_25 = @working_years_25
    gon.working_years_30 = @working_years_30
    gon.working_years_35 = @working_years_35
    gon.working_years_40_up = @working_years_40_up
  ## 工龄分析-饼图数据配置---结束

  ## 路龄分析-饼图数据配置---开始
    # 把各个路龄段的人数捞出，赋值给对应的实例变量
    @rali_years_5_below = Employee.where(rali_years: 0...5).count
    @rali_years_5 = Employee.where(rali_years: 5...10).count
    @rali_years_10 = Employee.where(rali_years: 10...15).count
    @rali_years_15 = Employee.where(rali_years: 15...20).count
    @rali_years_20 = Employee.where(rali_years: 20...25).count
    @rali_years_25 = Employee.where(rali_years: 25...30).count
    @rali_years_30 = Employee.where(rali_years: 30...35).count
    @rali_years_35_up = Employee.where(rali_years: 35..100).count
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
    gon.rali_years_5_below = @rali_years_5_below
    gon.rali_years_5 = @rali_years_5
    gon.rali_years_10 = @rali_years_10
    gon.rali_years_15 = @rali_years_15
    gon.rali_years_20 = @rali_years_20
    gon.rali_years_25 = @rali_years_25
    gon.rali_years_30 = @rali_years_30
    gon.rali_years_35_up = @rali_years_35_up
  ## 路龄分析-饼图数据配置---结束

  ## 条形图数据配置---开始
    #捞出所有的车间，赋值给实例变量
    @workshops = Employee.pluck("workshop").uniq
    #生成【车间-人数】hash---开始
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
    #定义每种学历各个车间的hash（包括在循环里使用的和最后存入的）
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
    #定义每个工龄段各个车间的hash（包括在循环里使用的和最后存入的）
    loop_hash_working_5_below = {}
    hash_working_5_below = {}
    loop_hash_working_5 = {}
    hash_working_5 = {}
    loop_hash_working_10 = {}
    hash_working_10 = {}
    loop_hash_working_15 = {}
    hash_working_15 = {}
    loop_hash_working_20 = {}
    hash_working_20 = {}
    loop_hash_working_25 = {}
    hash_working_25 = {}
    loop_hash_working_30 = {}
    hash_working_30 = {}
    loop_hash_working_35 = {}
    hash_working_35 = {}
    loop_hash_working_40_up = {}
    hash_working_40_up = {}
    #定义每个路龄段各个车间的hash（包括在循环里使用的和最后存入的）
    loop_hash_rali_5_below = {}
    hash_rali_5_below = {}
    loop_hash_rali_5 = {}
    hash_rali_5 = {}
    loop_hash_rali_10 = {}
    hash_rali_10 = {}
    loop_hash_rali_15 = {}
    hash_rali_15 = {}
    loop_hash_rali_20 = {}
    hash_rali_20 = {}
    loop_hash_rali_25 = {}
    hash_rali_25 = {}
    loop_hash_rali_30 = {}
    hash_rali_30 = {}
    loop_hash_rali_35_up = {}
    hash_rali_35_up = {}
    #生成【车间-人数】hash---结束

    #使用循环把车间和人数存成hash
    @workshops.each do |i|
      #把每个车间的总人数存成变量
      emp = Employee.where(workshop: i).count
      #年龄、学历、工龄、路龄在各车间的人数
      a1 = Employee.where(workshop: i, age: 0...25).count
      aa1 = Employee.where(workshop: i, education_background: "初中").count
      ba1 = Employee.where(workshop: i, working_years: 0...5).count
      ca1 = Employee.where(workshop: i, rali_years: 0...5).count
      #算出各维度人数占总人数的比重
      a = (a1.to_f)/(emp.to_f)
      aa = (aa1.to_f)/(emp.to_f)
      ba = (ba1.to_f)/(emp.to_f)
      ca = (ca1.to_f)/(emp.to_f)
      #将每一次的计算结果存成"车间 => 百分比"的hash
      loop_hash_25_below = {i => a}
      loop_hash_junior_high_school = {i => aa}
      loop_hash_working_5_below = {i => ba}
      loop_hash_rali_5_below = {i => ca}
      #将每一次的hash结果存到最终的结果里，供之后使用
      hash_25_below[i] = loop_hash_25_below[i]
      hash_junior_high_school[i] = loop_hash_junior_high_school[i]
      hash_working_5_below[i] = loop_hash_working_5_below[i]
      hash_rali_5_below[i] = loop_hash_rali_5_below[i]


      b1 = Employee.where(workshop: i, age: 25...30).count
      ab1 = Employee.where(workshop: i, education_background: "小学").count
      bb1 = Employee.where(workshop: i, working_years: 5...10).count
      cb1 = Employee.where(workshop: i, rali_years: 5...10).count
      b = (b1.to_f)/(emp.to_f)
      ab = (ab1.to_f)/(emp.to_f)
      bb = (bb1.to_f)/(emp.to_f)
      cb = (cb1.to_f)/(emp.to_f)
      loop_hash_25 = {i => b}
      loop_hash_primary_school = {i => ab}
      loop_hash_working_5 = {i => bb}
      loop_hash_rali_5 = {i => cb}
      hash_25[i] = loop_hash_25[i]
      hash_primary_school[i] = loop_hash_primary_school[i]
      hash_working_5[i] = loop_hash_working_5[i]
      hash_rali_5[i] = loop_hash_rali_5[i]

      c1 = Employee.where(workshop: i, age: 30...35).count
      ac1 = Employee.where(workshop: i, education_background: "高中").count
      bc1 = Employee.where(workshop: i, working_years: 10...15).count
      cc1 = Employee.where(workshop: i, rali_years: 10...15).count
      c = (c1.to_f)/(emp.to_f)
      ac = (ac1.to_f)/(emp.to_f)
      bc = (bc1.to_f)/(emp.to_f)
      cc = (cc1.to_f)/(emp.to_f)
      loop_hash_30 = {i => c}
      loop_hash_senior_high_school = {i => ac}
      loop_hash_working_10 = {i => bc}
      loop_hash_rali_10 = {i => cc}
      hash_30[i] = loop_hash_30[i]
      hash_senior_high_school[i] = loop_hash_senior_high_school[i]
      hash_working_10[i] = loop_hash_working_10[i]
      hash_rali_10[i] = loop_hash_rali_10[i]

      d1 = Employee.where(workshop: i, age: 35...40).count
      ad1 = Employee.where(workshop: i, education_background: "技校").count
      bd1 = Employee.where(workshop: i, working_years: 15...20).count
      cd1 = Employee.where(workshop: i, rali_years: 15...20).count
      d = (d1.to_f)/(emp.to_f)
      ad = (ad1.to_f)/(emp.to_f)
      bd = (bd1.to_f)/(emp.to_f)
      cd = (cd1.to_f)/(emp.to_f)
      loop_hash_35 = {i => d}
      loop_hash_technical_school = {i => ad}
      loop_hash_working_15 = {i => bd}
      loop_hash_rali_15 = {i => cd}
      hash_35[i] = loop_hash_35[i]
      hash_technical_school[i] = loop_hash_technical_school[i]
      hash_working_15[i] = loop_hash_working_15[i]
      hash_rali_15[i] = loop_hash_rali_15[i]

      e1 = Employee.where(workshop: i, age: 40...45).count
      ae1 = Employee.where(workshop: i, education_background: "中专").count
      be1 = Employee.where(workshop: i, working_years: 20...25).count
      ce1 = Employee.where(workshop: i, rali_years: 20...25).count
      e = (e1.to_f)/(emp.to_f)
      ae = (ae1.to_f)/(emp.to_f)
      be = (be1.to_f)/(emp.to_f)
      ce = (ce1.to_f)/(emp.to_f)
      loop_hash_40 = {i => e}
      loop_hash_secondary_school = {i => ae}
      loop_hash_working_20 = {i => be}
      loop_hash_rali_20 = {i => ce}
      hash_40[i] = loop_hash_40[i]
      hash_secondary_school[i] = loop_hash_secondary_school[i]
      hash_working_20[i] = loop_hash_working_20[i]
      hash_rali_20[i] = loop_hash_rali_20[i]

      f1 = Employee.where(workshop: i, age: 45...50).count
      af1 = Employee.where(workshop: i, education_background: "大学专科").count
      bf1 = Employee.where(workshop: i, working_years: 25...30).count
      cf1 = Employee.where(workshop: i, rali_years: 25...30).count
      f = (f1.to_f)/(emp.to_f)
      af = (af1.to_f)/(emp.to_f)
      bf = (bf1.to_f)/(emp.to_f)
      cf = (cf1.to_f)/(emp.to_f)
      loop_hash_45 = {i => f}
      loop_hash_university_specialties = {i => af}
      loop_hash_working_25 = {i => bf}
      loop_hash_rali_25 = {i => cf}
      hash_45[i] = loop_hash_45[i]
      hash_university_specialties[i] = loop_hash_university_specialties[i]
      hash_working_25[i] = loop_hash_working_25[i]
      hash_rali_25[i] = loop_hash_rali_25[i]

      g1 = Employee.where(workshop: i, age: 50...55).count
      ag1 = Employee.where(workshop: i, education_background: "大学本科").count
      bg1 = Employee.where(workshop: i, working_years: 30...35).count
      cg1 = Employee.where(workshop: i, rali_years: 30...35).count
      g = (g1.to_f)/(emp.to_f)
      ag = (ag1.to_f)/(emp.to_f)
      bg = (bg1.to_f)/(emp.to_f)
      cg = (cg1.to_f)/(emp.to_f)
      loop_hash_50 = {i => g}
      loop_hash_undergraduate = {i => ag}
      loop_hash_working_30 = {i => bg}
      loop_hash_rali_30 = {i => cg}
      hash_50[i] = loop_hash_50[i]
      hash_undergraduate[i] = loop_hash_undergraduate[i]
      hash_working_30[i] = loop_hash_working_30[i]
      hash_rali_30[i] = loop_hash_rali_30[i]

      h1 = Employee.where(workshop: i, age: 55..70).count
      ah1 = Employee.where(workshop: i, education_background: "研究生").count
      bh1 = Employee.where(workshop: i, working_years: 35...40).count
      ch1 = Employee.where(workshop: i, rali_years: 35..100).count
      h = (h1.to_f)/(emp.to_f)
      ah = (ah1.to_f)/(emp.to_f)
      bh = (bh1.to_f)/(emp.to_f)
      ch = (ch1.to_f)/(emp.to_f)
      loop_hash_55 = {i => h}
      loop_hash_postgraduate = {i => ah}
      loop_hash_working_35 = {i => bh}
      loop_hash_rali_35_up = {i => ch}
      hash_55[i] = loop_hash_55[i]
      hash_postgraduate[i] = loop_hash_postgraduate[i]
      hash_working_35[i] = loop_hash_working_35[i]
      hash_rali_35_up[i] = loop_hash_rali_35_up[i]

      bj1 = Employee.where(workshop: i, working_years: 40..100).count
      bj = (bj1.to_f)/(emp.to_f)
      loop_hash_working_40_up = {i => bj}
      hash_working_40_up[i] = loop_hash_working_40_up[i]

    end
    #生成每个年龄段的【车间-人数】hash---结束

    # 使用'gon'这个gem的方法来赋值变量，在js中使用
    # 将以上算出最终hash的keys赋值给变量，作为条形图的坐标轴
    gon.bar_workshop = hash_25_below.keys
    #将以上算出最终hash的values赋值给对应的变量，作为条形图的数据
    #年龄分析条形图
    gon.bar_twenty_five_below = hash_25_below.values
    gon.bar_twenty_five = hash_25.values
    gon.bar_thirty = hash_30.values
    gon.bar_thirty_five = hash_35.values
    gon.bar_forty = hash_40.values
    gon.bar_forty_five = hash_45.values
    gon.bar_fifty = hash_50.values
    gon.bar_fifty_five = hash_55.values
    #学历分析条形图
    gon.bar_junior_high_school = hash_junior_high_school.values
    gon.bar_primary_school = hash_primary_school.values
    gon.bar_senior_high_school = hash_senior_high_school.values
    gon.bar_technical_school = hash_technical_school.values
    gon.bar_secondary_school = hash_secondary_school.values
    gon.bar_university_specialties = hash_university_specialties.values
    gon.bar_undergraduate = hash_undergraduate.values
    gon.bar_postgraduate = hash_postgraduate.values
    #工龄分析条形图
    gon.bar_working_5_below = hash_working_5_below.values
    gon.bar_working_5 = hash_working_5.values
    gon.bar_working_10 = hash_working_10.values
    gon.bar_working_15 = hash_working_15.values
    gon.bar_working_20 = hash_working_20.values
    gon.bar_working_25 = hash_working_25.values
    gon.bar_working_30 = hash_working_30.values
    gon.bar_working_35 = hash_working_35.values
    gon.bar_working_40_up = hash_working_40_up.values
    #路龄分析条形图
    gon.bar_rali_5_below = hash_rali_5_below.values
    gon.bar_rali_5 = hash_rali_5.values
    gon.bar_rali_10 = hash_rali_10.values
    gon.bar_rali_15 = hash_rali_15.values
    gon.bar_rali_20 = hash_rali_20.values
    gon.bar_rali_25 = hash_rali_25.values
    gon.bar_rali_30 = hash_rali_30.values
    gon.bar_rali_35 = hash_rali_35_up.values
    ## 条形图数据配置---结束
  end
### 统计分析页面的图表数据配置---结束

###点击图表详情页面数据配置---开始
  def statistical_analysis_data
    ##含有workshop参数的都为条形图，以下为条形图数据配置
    if params[:workshop].present?
      #年龄分析条形图
      if params[:age].present?
        case params[:age]
        when "25岁以下"
          @employees = Employee.where(workshop: params[:workshop], age: 0...25)
        when "25-30岁"
          @employees = Employee.where(workshop: params[:workshop], age: 25...30)
        when "30-35岁"
          @employees = Employee.where(workshop: params[:workshop], age: 30...35)
        when "35-40岁"
          @employees = Employee.where(workshop: params[:workshop], age: 35...40)
        when "40-45岁"
          @employees = Employee.where(workshop: params[:workshop], age: 40...45)
        when "45-50岁"
          @employees = Employee.where(workshop: params[:workshop], age: 45...50)
        when "50-55岁"
          @employees = Employee.where(workshop: params[:workshop], age: 50...55)
        when "55岁以上"
          @employees = Employee.where(workshop: params[:workshop], age: 55..60)
        end
      #学历分析条形图
      elsif params[:education].present?
        @employees = Employee.where(workshop: params[:workshop], education_background: params[:education])
      #工龄分析条形图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          @employees = Employee.where(workshop: params[:workshop], working_years: 0...5)
        when "5-10年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 5...10)
        when "10-15年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 10...15)
        when "15-20年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 15...20)
        when "20-25年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 20...25)
        when "25-30年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 25...30)
        when "30-35年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 30...35)
        when "35-40年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 35...40)
        when "40年以上"
          @employees = Employee.where(workshop: params[:workshop], working_years: 40..100)
        end
      #路龄分析条形图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 0...5)
        when "5-10年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 5...10)
        when "10-15年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 10...15)
        when "15-20年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 15...20)
        when "20-25年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 20...25)
        when "25-30年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 25...30)
        when "30-35年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 30...35)
        when "35年以上"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 35..100)
        end
      end
    ##没有workshop参数则为饼图，以下为饼图数据配置
    else
      #年龄分析饼图
      if params[:age].present?
        case params[:age]
        when "25岁以下"
          @employees = Employee.where(age: 0...25)
        when "25-30岁"
          @employees = Employee.where(age: 25...30)
        when "30-35岁"
          @employees = Employee.where(age: 30...35)
        when "35-40岁"
          @employees = Employee.where(age: 35...40)
        when "40-45岁"
          @employees = Employee.where(age: 40...45)
        when "45-50岁"
          @employees = Employee.where(age: 45...50)
        when "50-55岁"
          @employees = Employee.where(age: 50...55)
        when "55岁以上"
          @employees = Employee.where(age: 55..60)
        end
      #学历分析饼图
      elsif params[:education].present?
        @employees = Employee.where(education_background: params[:education])
      #工龄分析饼图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          @employees = Employee.where(working_years: 0...5)
        when "5-10年"
          @employees = Employee.where(working_years: 5...10)
        when "10-15年"
          @employees = Employee.where(working_years: 10...15)
        when "15-20年"
          @employees = Employee.where(working_years: 15...20)
        when "20-25年"
          @employees = Employee.where(working_years: 20...25)
        when "25-30年"
          @employees = Employee.where(working_years: 25...30)
        when "30-35年"
          @employees = Employee.where(working_years: 30...35)
        when "35-40年"
          @employees = Employee.where(working_years: 35...40)
        when "40年以上"
          @employees = Employee.where(working_years: 40..100)
        end
      #路龄分析饼图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          @employees = Employee.where(rali_years: 0...5)
        when "5-10年"
          @employees = Employee.where(rali_years: 5...10)
        when "10-15年"
          @employees = Employee.where(rali_years: 10...15)
        when "15-20年"
          @employees = Employee.where(rali_years: 15...20)
        when "20-25年"
          @employees = Employee.where(rali_years: 20...25)
        when "25-30年"
          @employees = Employee.where(rali_years: 25...30)
        when "30-35年"
          @employees = Employee.where(rali_years: 30...35)
        when "35年以上"
          @employees = Employee.where(rali_years: 35..100)
        end
      end
    end
  end
###点击图表详情页面数据配置---结束

###组织架构页面数据配置
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
