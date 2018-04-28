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

###年龄、工龄、路龄、学历图表分析页面数据配置---开始
  ##年龄分析
  def age_statistical_analysis
    #年龄分析---饼图数据设置---开始
    # 把各个年龄段的人数捞出，赋值给对应的实例变量
    @age_25_below = Employee.where(age: 0...25).count
    @age_25 = Employee.where(age: 25...30).count
    @age_30 = Employee.where(age: 30...35).count
    @age_35 = Employee.where(age: 35...40).count
    @age_40 = Employee.where(age: 40...45).count
    @age_45 = Employee.where(age: 45...50).count
    @age_50 = Employee.where(age: 50...55).count
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
    #年龄分析---饼图数据设置---结束
    #年龄分析---条形图数据设置---开始
    @workshops = Employee.pluck("workshop").uniq
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

      @age_25_below_bar = []
      @age_25_bar = []
      @age_30_bar = []
      @age_35_bar = []
      @age_40_bar = []
      @age_45_bar = []
      @age_50_bar = []
      @age_55_bar = []
      #使用循环把车间和人数存成hash
      @workshops.each do |i|
        #把每个车间的总人数存成变量
        emp = Employee.where(workshop: i).count
        #把各年龄段在各车间的人数存成变量
        a1 = Employee.where(workshop: i, age: 0...25).count      
        #算出各年龄段人数占车间总人数的比重
        a = (a1.to_f)/(emp.to_f)      
        #将每一次的计算结果存成"车间 => 百分比"的hash
        loop_hash_25_below = {i => a}     
        #将每一次的hash结果存到最终的hash里，供之后使用
        hash_25_below[i] = loop_hash_25_below[i]
        @age_25_below_bar << a1

        b1 = Employee.where(workshop: i, age: 25...30).count      
        b = (b1.to_f)/(emp.to_f)     
        loop_hash_25 = {i => b}      
        hash_25[i] = loop_hash_25[i]
        @age_25_bar << b1
        
        c1 = Employee.where(workshop: i, age: 30...35).count      
        c = (c1.to_f)/(emp.to_f)     
        loop_hash_30 = {i => c}      
        hash_30[i] = loop_hash_30[i]
        @age_30_bar << c1
      
        d1 = Employee.where(workshop: i, age: 35...40).count     
        d = (d1.to_f)/(emp.to_f)    
        loop_hash_35 = {i => d}     
        hash_35[i] = loop_hash_35[i]  
        @age_35_bar << d1  

        e1 = Employee.where(workshop: i, age: 40...45).count     
        e = (e1.to_f)/(emp.to_f)    
        loop_hash_40 = {i => e}     
        hash_40[i] = loop_hash_40[i]
        @age_40_bar << e1
       
        f1 = Employee.where(workshop: i, age: 45...50).count      
        f = (f1.to_f)/(emp.to_f)     
        loop_hash_45 = {i => f}      
        hash_45[i] = loop_hash_45[i]
        @age_45_bar << f1

        g1 = Employee.where(workshop: i, age: 50...55).count     
        g = (g1.to_f)/(emp.to_f)    
        loop_hash_50 = {i => g}    
        hash_50[i] = loop_hash_50[i]
        @age_50_bar << g1

        h1 = Employee.where(workshop: i, age: 55..70).count     
        h = (h1.to_f)/(emp.to_f)    
        loop_hash_55 = {i => h}     
        hash_55[i] = loop_hash_55[i]
        @age_55_bar << h1
      end
      #生成每个年龄段的【车间-人数】hash---结束

    #将以上算出最终hash的keys赋值给对应的变量，作为条形图的坐标轴信息
    gon.bar_workshop = hash_25_below.keys
    #将以上算出最终hash的values赋值给对应的变量，作为条形图的数据
    gon.bar_twenty_five_below = hash_25_below.values
    gon.bar_twenty_five = hash_25.values
    gon.bar_thirty = hash_30.values
    gon.bar_thirty_five = hash_35.values
    gon.bar_forty = hash_40.values
    gon.bar_forty_five = hash_45.values
    gon.bar_fifty = hash_50.values
    gon.bar_fifty_five = hash_55.values
    
    #年龄分析---条形图数据设置---结束
  end

  def education_statistical_analysis
    @junior_high_school = Employee.where(education_background: ["初中"]).count
    @primary_school = Employee.where(education_background: ["小学"]).count
    @senior_high_school = Employee.where(education_background: "高中").count
    @technical_school = Employee.where(education_background: "技校").count
    @secondary_school = Employee.where(education_background: "中专").count
    @university_specialties = Employee.where(education_background: "大学专科").count
    @undergraduate = Employee.where(education_background: "大学本科").count
    @postgraduate = Employee.where(education_background: "研究生").count

    gon.junior_high_school = @junior_high_school_below
    gon.senior_high_school = @senior_high_school
    gon.technical_school =  @technical_school
    gon.secondary_school =  @secondary_school
    gon.university_specialties =  @university_specialties
    gon.undergraduate = @undergraduate
    gon.postgraduate = @postgraduate
    gon.primary_school = @primary_school

    @workshops = Employee.pluck("workshop").uniq
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

    @junior_high_school_bar = []
    @primary_school_bar = []
    @senior_high_school_bar = []
    @technical_school_bar = []
    @secondary_school_bar = []
    @university_specialties_bar = []
    @undergraduate_bar = []
    @postgraduate_bar = []
    @workshops.each do |i|
      emp = Employee.where(workshop: i).count     
      a1 = Employee.where(workshop: i, education_background: "初中").count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_junior_high_school = {i => a}
      hash_junior_high_school[i] = loop_hash_junior_high_school[i]
      @junior_high_school_bar << a1

      b1 = Employee.where(workshop: i, education_background: "小学").count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_primary_school = {i => b}
      hash_primary_school[i] = loop_hash_primary_school[i]
      @primary_school_bar << b1

      c1 = Employee.where(workshop: i, education_background: "高中").count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_senior_high_school = {i => c}
      hash_senior_high_school[i] = loop_hash_senior_high_school[i]
      @senior_high_school_bar << c1

      d1 = Employee.where(workshop: i, education_background: "技校").count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_technical_school = {i => d}
      hash_technical_school[i] = loop_hash_technical_school[i]
      @technical_school_bar << d1

      e1 = Employee.where(workshop: i, education_background: "中专").count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_secondary_school = {i => e}
      hash_secondary_school[i] = loop_hash_secondary_school[i]
      @secondary_school_bar << e1

      f1 = Employee.where(workshop: i, education_background: "大学专科").count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_university_specialties = {i => f}
      hash_university_specialties[i] = loop_hash_university_specialties[i]
      @university_specialties_bar << f1

      g1 = Employee.where(workshop: i, education_background: "大学本科").count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_undergraduate = {i => g}
      hash_undergraduate[i] = loop_hash_undergraduate[i]
      @undergraduate_bar << g1

      h1 = Employee.where(workshop: i, education_background: "研究生").count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_postgraduate = {i => h}
      hash_postgraduate[i] = loop_hash_postgraduate[i]
      @postgraduate_bar << h1
    end
    gon.bar_workshop = hash_junior_high_school.keys
    gon.bar_junior_high_school = hash_junior_high_school.values
    gon.bar_primary_school = hash_primary_school.values
    gon.bar_senior_high_school = hash_senior_high_school.values
    gon.bar_technical_school = hash_technical_school.values
    gon.bar_secondary_school = hash_secondary_school.values
    gon.bar_university_specialties = hash_university_specialties.values
    gon.bar_undergraduate = hash_undergraduate.values
    gon.bar_postgraduate = hash_postgraduate.values
  end

  def working_years_statistical_analysis
    @working_years_5_below = Employee.where(working_years: 0...5).count
    @working_years_5 = Employee.where(working_years: 5...10).count
    @working_years_10 = Employee.where(working_years: 10...15).count
    @working_years_15 = Employee.where(working_years: 15...20).count
    @working_years_20 = Employee.where(working_years: 20...25).count
    @working_years_25 = Employee.where(working_years: 25...30).count
    @working_years_30 = Employee.where(working_years: 30...35).count
    @working_years_35 = Employee.where(working_years: 35...40).count
    @working_years_40_up = Employee.where(working_years: 40..100).count

    gon.working_years_5_below = @working_years_5_below
    gon.working_years_5 = @working_years_5
    gon.working_years_10 = @working_years_10
    gon.working_years_15 = @working_years_15
    gon.working_years_20 = @working_years_20
    gon.working_years_25 = @working_years_25
    gon.working_years_30 = @working_years_30
    gon.working_years_35 = @working_years_35
    gon.working_years_40_up = @working_years_40_up
    
    @workshops = Employee.pluck("workshop").uniq
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

    @working_5_below_bar = []
    @working_5_bar = []
    @working_10_bar = []
    @working_15_bar = []
    @working_20_bar = []
    @working_25_bar = []
    @working_30_bar = []
    @working_35_bar = []
    @working_40_up_bar = []

    @workshops.each do |i|
      emp = Employee.where(workshop: i).count
      a1 = Employee.where(workshop: i, working_years: 0...5).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_working_5_below = {i => a}
      hash_working_5_below[i] = loop_hash_working_5_below[i]
      @working_5_below_bar << a1

      b1 = Employee.where(workshop: i, working_years: 5...10).count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_working_5 = {i => b}
      hash_working_5[i] = loop_hash_working_5[i]
      @working_5_bar << b1

      c1 = Employee.where(workshop: i, working_years: 10...15).count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_working_10 = {i => c}
      hash_working_10[i] = loop_hash_working_10[i]
      @working_10_bar << c1

      d1 = Employee.where(workshop: i, working_years: 15...20).count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_working_15 = {i => d}
      hash_working_15[i] = loop_hash_working_15[i]
      @working_15_bar << d1

      e1 = Employee.where(workshop: i, working_years: 20...25).count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_working_20 = {i => e}
      hash_working_20[i] = loop_hash_working_20[i]
      @working_20_bar << e1

      f1 = Employee.where(workshop: i, working_years: 25...30).count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_working_25 = {i => f}
      hash_working_25[i] = loop_hash_working_25[i]
      @working_25_bar << f1

      g1 = Employee.where(workshop: i, working_years: 30...35).count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_working_30 = {i => g}
      hash_working_30[i] = loop_hash_working_30[i]
      @working_30_bar << g1

      h1 = Employee.where(workshop: i, working_years: 35...40).count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_working_35 = {i => h}
      hash_working_35[i] = loop_hash_working_35[i]
      @working_35_bar << h1

      j1 = Employee.where(workshop: i, working_years: 40..100).count
      j = (j1.to_f)/(emp.to_f)
      loop_hash_working_40_up = {i => j}
      hash_working_40_up[i] = loop_hash_working_40_up[i]
      @working_40_up_bar << j1

      gon.bar_workshop = hash_working_5_below.keys
      gon.bar_working_5_below = hash_working_5_below.values
      gon.bar_working_5 = hash_working_5.values
      gon.bar_working_10 = hash_working_10.values
      gon.bar_working_15 = hash_working_15.values
      gon.bar_working_20 = hash_working_20.values
      gon.bar_working_25 = hash_working_25.values
      gon.bar_working_30 = hash_working_30.values
      gon.bar_working_35 = hash_working_35.values
      gon.bar_working_40_up = hash_working_40_up.values
    end
  end

  def rali_years_statistical_analysis
    @rali_years_5_below = Employee.where(rali_years: 0...5).count
    @rali_years_5 = Employee.where(rali_years: 5...10).count
    @rali_years_10 = Employee.where(rali_years: 10...15).count
    @rali_years_15 = Employee.where(rali_years: 15...20).count
    @rali_years_20 = Employee.where(rali_years: 20...25).count
    @rali_years_25 = Employee.where(rali_years: 25...30).count
    @rali_years_30 = Employee.where(rali_years: 30...35).count
    @rali_years_35_up = Employee.where(rali_years: 35..100).count

    gon.rali_years_5_below = @rali_years_5_below
    gon.rali_years_5 = @rali_years_5
    gon.rali_years_10 = @rali_years_10
    gon.rali_years_15 = @rali_years_15
    gon.rali_years_20 = @rali_years_20
    gon.rali_years_25 = @rali_years_25
    gon.rali_years_30 = @rali_years_30
    gon.rali_years_35_up = @rali_years_35_up

  @workshops = Employee.pluck("workshop").uniq
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

    @workshops.each do |i|
      emp = Employee.where(workshop: i).count
      ca1 = Employee.where(workshop: i, rali_years: 0...5).count
      ca = (ca1.to_f)/(emp.to_f)
      loop_hash_rali_5_below = {i => ca}
      hash_rali_5_below[i] = loop_hash_rali_5_below[i]

      cb1 = Employee.where(workshop: i, rali_years: 5...10).count
      cb = (cb1.to_f)/(emp.to_f)
      loop_hash_rali_5 = {i => cb}
      hash_rali_5[i] = loop_hash_rali_5[i]

      cc1 = Employee.where(workshop: i, rali_years: 10...15).count
      cc = (cc1.to_f)/(emp.to_f)
      loop_hash_rali_10 = {i => cc}
      hash_rali_10[i] = loop_hash_rali_10[i]

      cd1 = Employee.where(workshop: i, rali_years: 15...20).count
      cd = (cd1.to_f)/(emp.to_f)
      loop_hash_rali_15 = {i => cd}
      hash_rali_15[i] = loop_hash_rali_15[i]

      ce1 = Employee.where(workshop: i, rali_years: 20...25).count
      ce = (ce1.to_f)/(emp.to_f)
      loop_hash_rali_20 = {i => ce}
      hash_rali_20[i] = loop_hash_rali_20[i]

      cf1 = Employee.where(workshop: i, rali_years: 25...30).count
      cf = (cf1.to_f)/(emp.to_f)
      loop_hash_rali_25 = {i => cf}
      hash_rali_25[i] = loop_hash_rali_25[i]

      cg1 = Employee.where(workshop: i, rali_years: 30...35).count
      cg = (cg1.to_f)/(emp.to_f)
      loop_hash_rali_30 = {i => cg}
      hash_rali_30[i] = loop_hash_rali_30[i]

      ch1 = Employee.where(workshop: i, rali_years: 35..100).count
      ch = (ch1.to_f)/(emp.to_f)
      loop_hash_rali_35_up = {i => ch}
      hash_rali_35_up[i] = loop_hash_rali_35_up[i]
    end

    gon.bar_workshop = hash_rali_5_below.keys
    gon.bar_rali_5_below = hash_rali_5_below.values
    gon.bar_rali_5 = hash_rali_5.values
    gon.bar_rali_10 = hash_rali_10.values
    gon.bar_rali_15 = hash_rali_15.values
    gon.bar_rali_20 = hash_rali_20.values
    gon.bar_rali_25 = hash_rali_25.values
    gon.bar_rali_30 = hash_rali_30.values
    gon.bar_rali_35 = hash_rali_35_up.values
  end
###年龄、工龄、路龄、学历图表分析页面数据配置---结束

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
