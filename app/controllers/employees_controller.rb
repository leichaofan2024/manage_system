class EmployeesController < ApplicationController
  layout 'home'

  def index
    #按工种筛选和默认显示的情况 和每个车间、班组登录只能看到自己的部门的人
    if params[:worktype].present?
      @employees = Employee.where(work_type: params[:work_type]).page(params[:page]).per(10)
    elsif (current_user.has_role? :superadmin) || (current_user.has_role? :empadmin) || (current_user.has_role? :attendance_admin) || (current_user.has_role? :limitadmin) || (current_user.has_role? :awardadmin)
      @employees = Employee.order('id ASC').page(params[:page]).per(10)
    elsif current_user.has_role? :organsadmin
      group_id = Group.find_by(:name => current_user.name).id
      @employees = Employee.where(:group => group_id).page(params[:page]).per(10)
    else
      group_name = current_user.name.split("-")[1]
      group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
      @employees = Employee.where(:workshop => group.workshop_id,:group => group.id).page(params[:page])
    end
    #下载表格配置
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

 #上传表格
  def import_table
    Employee.import_table(params[:file])
    redirect_to employees_path
  end

  #搜索和筛选--开始
  def search
    if current_user.has_role? :organsadmin
      @employees = Employee.search_records(params[:q]).where(:group => Group.find_by_name(current_user.name).id)
    elsif (current_user.has_role? :superadmin) || (current_user.has_role? :empadmin) || (current_user.has_role? :attendance_admin) || (current_user.has_role? :limitadmin) || (current_user.has_role? :awardadmin)
      @employees = Employee.search_records(params[:q])
    elsif current_user.has_role? :workshopadmin
      @employees = Employee.search_records(params[:q]).where(:workshop => Workshop.find_by_name(current_user.name).id)
    else
      @employees = Employee.search_records(params[:q]).where(:workshop => Workshop.find_by_name(current_user.name.split("-")[0]).id,:group => Group.find_by_name(current_user.name.split("-")[1]).id)
    end
    render action: "index"
  end

  def filter
    case params[:filter_type]
    when "年龄"
      @employees = Employee.where(age: params[:start_time]..params[:end_time])
    when "工龄"
      @employees = Employee.where(working_years: params[:start_time]..params[:end_time])
    when "路龄"
      @employees = Employee.where(rali_years: params[:start_time]..params[:end_time])
    end
    render action: "index"
  end
  #搜索和筛选--结束

  #一键更新
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

###年龄、工龄、路龄、学历图表分析页面数据配置---开始
  ##年龄分析
  def age_statistical_analysis
    #年龄分析---饼图数据设置---开始
    # 把各个年龄段的人数捞出，赋值给对应的实例变量
    @age_25_below = Employee.where(age: 0..25).count
    @age_26 = Employee.where(age: 26..30).count
    @age_31 = Employee.where(age: 31..35).count
    @age_36 = Employee.where(age: 36..40).count
    @age_41 = Employee.where(age: 41..45).count
    @age_46 = Employee.where(age: 46..50).count
    @age_51 = Employee.where(age: 51..55).count
    @age_56_up = Employee.where(age: 56..100).count
    # 使用'gon'这个gem的方法，将数据赋值给对应的变量，在js中使用
    gon.twenty_five_below = @age_25_below
    gon.twenty_six = @age_26
    gon.thirty_one =  @age_31
    gon.thirty_six =  @age_36
    gon.forty_one =  @age_41
    gon.forty_six = @age_46
    gon.fifty_one = @age_51
    gon.fifty_six_up = @age_56_up
    #年龄分析---饼图数据设置---结束
    #年龄分析---条形图数据设置---开始
    @workshops = Employee.pluck("workshop").uniq
      #定义每个年龄段各个车间的hash（包括在循环里使用的和最后存入的）
      loop_hash_25_below = {}
      hash_25_below = {}
      loop_hash_26 = {}
      hash_26 = {}
      loop_hash_31 = {}
      hash_31 = {}
      loop_hash_36 = {}
      hash_36 = {}
      loop_hash_41 = {}
      hash_41 = {}
      loop_hash_46 = {}
      hash_46 = {}
      loop_hash_51 = {}
      hash_51 = {}
      loop_hash_56_up = {}
      hash_56_up = {}

      @age_25_below_bar = []
      @age_26_bar = []
      @age_31_bar = []
      @age_36_bar = []
      @age_41_bar = []
      @age_46_bar = []
      @age_51_bar = []
      @age_56_up_bar = []
      #使用循环把车间和人数存成hash
      @workshops.each do |i|
        #把每个车间的总人数存成变量
        emp = Employee.where(workshop: i).count
        #把各年龄段在各车间的人数存成变量
        a1 = Employee.where(workshop: i, age: 0..25).count
        #算出各年龄段人数占车间总人数的比重
        a = (a1.to_f)/(emp.to_f)
        #将每一次的计算结果存成"车间 => 百分比"的hash
        loop_hash_25_below = {i => a}
        #将每一次的hash结果存到最终的hash里，供之后使用
        hash_25_below[i] = loop_hash_25_below[i]
        @age_25_below_bar << a1

        b1 = Employee.where(workshop: i, age: 26..30).count
        b = (b1.to_f)/(emp.to_f)
        loop_hash_26 = {i => b}
        hash_26[i] = loop_hash_26[i]
        @age_26_bar << b1

        c1 = Employee.where(workshop: i, age: 31..35).count
        c = (c1.to_f)/(emp.to_f)
        loop_hash_31 = {i => c}
        hash_31[i] = loop_hash_31[i]
        @age_31_bar << c1

        d1 = Employee.where(workshop: i, age: 36..40).count
        d = (d1.to_f)/(emp.to_f)
        loop_hash_36 = {i => d}
        hash_36[i] = loop_hash_36[i]
        @age_36_bar << d1

        e1 = Employee.where(workshop: i, age: 41..45).count
        e = (e1.to_f)/(emp.to_f)
        loop_hash_41 = {i => e}
        hash_41[i] = loop_hash_41[i]
        @age_41_bar << e1

        f1 = Employee.where(workshop: i, age: 46..50).count
        f = (f1.to_f)/(emp.to_f)
        loop_hash_46 = {i => f}
        hash_46[i] = loop_hash_46[i]
        @age_46_bar << f1

        g1 = Employee.where(workshop: i, age: 51..55).count
        g = (g1.to_f)/(emp.to_f)
        loop_hash_51 = {i => g}
        hash_51[i] = loop_hash_51[i]
        @age_51_bar << g1

        h1 = Employee.where(workshop: i, age: 56..70).count
        h = (h1.to_f)/(emp.to_f)
        loop_hash_56_up = {i => h}
        hash_56_up[i] = loop_hash_56_up[i]
        @age_56_up_bar << h1
      end
      #生成每个年龄段的【车间-人数】hash---结束

    #将以上算出最终hash的keys赋值给对应的变量，作为条形图的坐标轴信息
    gon.bar_workshop = hash_25_below.keys
    #将以上算出最终hash的values赋值给对应的变量，作为条形图的数据
    gon.bar_twenty_five_below = hash_25_below.values
    gon.bar_twenty_six = hash_26.values
    gon.bar_thirty_one = hash_31.values
    gon.bar_thirty_six = hash_36.values
    gon.bar_forty_one = hash_41.values
    gon.bar_forty_six = hash_46.values
    gon.bar_fifty_one = hash_51.values
    gon.bar_fifty_six_up = hash_56_up.values

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
    @working_years_5_below = Employee.where(working_years: 0..5).count
    @working_years_6 = Employee.where(working_years: 6..10).count
    @working_years_11 = Employee.where(working_years: 11..15).count
    @working_years_16 = Employee.where(working_years: 16..20).count
    @working_years_21 = Employee.where(working_years: 21..25).count
    @working_years_26 = Employee.where(working_years: 26..30).count
    @working_years_31 = Employee.where(working_years: 31..35).count
    @working_years_36 = Employee.where(working_years: 36..40).count
    @working_years_41_up = Employee.where(working_years: 41..100).count

    gon.working_years_5_below = @working_years_5_below
    gon.working_years_6 = @working_years_6
    gon.working_years_11 = @working_years_11
    gon.working_years_16 = @working_years_16
    gon.working_years_21 = @working_years_21
    gon.working_years_26 = @working_years_26
    gon.working_years_31 = @working_years_31
    gon.working_years_36 = @working_years_36
    gon.working_years_41_up = @working_years_41_up

    @workshops = Employee.pluck("workshop").uniq
    loop_hash_working_5_below = {}
    hash_working_5_below = {}
    loop_hash_working_6 = {}
    hash_working_6 = {}
    loop_hash_working_11 = {}
    hash_working_11 = {}
    loop_hash_working_16 = {}
    hash_working_16 = {}
    loop_hash_working_21 = {}
    hash_working_21 = {}
    loop_hash_working_26 = {}
    hash_working_26 = {}
    loop_hash_working_31 = {}
    hash_working_31 = {}
    loop_hash_working_36 = {}
    hash_working_36 = {}
    loop_hash_working_41_up = {}
    hash_working_41_up = {}

    @working_5_below_bar = []
    @working_6_bar = []
    @working_11_bar = []
    @working_16_bar = []
    @working_21_bar = []
    @working_26_bar = []
    @working_31_bar = []
    @working_36_bar = []
    @working_41_up_bar = []

    @workshops.each do |i|
      emp = Employee.where(workshop: i).count
      a1 = Employee.where(workshop: i, working_years: 0..5).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_working_5_below = {i => a}
      hash_working_5_below[i] = loop_hash_working_5_below[i]
      @working_5_below_bar << a1

      b1 = Employee.where(workshop: i, working_years: 6..10).count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_working_6 = {i => b}
      hash_working_6[i] = loop_hash_working_6[i]
      @working_6_bar << b1

      c1 = Employee.where(workshop: i, working_years: 11..15).count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_working_11 = {i => c}
      hash_working_11[i] = loop_hash_working_11[i]
      @working_11_bar << c1

      d1 = Employee.where(workshop: i, working_years: 16..20).count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_working_16 = {i => d}
      hash_working_16[i] = loop_hash_working_16[i]
      @working_16_bar << d1

      e1 = Employee.where(workshop: i, working_years: 21..25).count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_working_21 = {i => e}
      hash_working_21[i] = loop_hash_working_21[i]
      @working_21_bar << e1

      f1 = Employee.where(workshop: i, working_years: 26..30).count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_working_26 = {i => f}
      hash_working_26[i] = loop_hash_working_26[i]
      @working_26_bar << f1

      g1 = Employee.where(workshop: i, working_years: 31..35).count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_working_31 = {i => g}
      hash_working_31[i] = loop_hash_working_31[i]
      @working_31_bar << g1

      h1 = Employee.where(workshop: i, working_years: 36..40).count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_working_36 = {i => h}
      hash_working_36[i] = loop_hash_working_36[i]
      @working_36_bar << h1

      j1 = Employee.where(workshop: i, working_years: 41..100).count
      j = (j1.to_f)/(emp.to_f)
      loop_hash_working_41_up = {i => j}
      hash_working_41_up[i] = loop_hash_working_41_up[i]
      @working_41_up_bar << j1

      gon.bar_workshop = hash_working_5_below.keys
      gon.bar_working_5_below = hash_working_5_below.values
      gon.bar_working_6 = hash_working_6.values
      gon.bar_working_11 = hash_working_11.values
      gon.bar_working_16 = hash_working_16.values
      gon.bar_working_21 = hash_working_21.values
      gon.bar_working_26 = hash_working_26.values
      gon.bar_working_31 = hash_working_31.values
      gon.bar_working_36 = hash_working_36.values
      gon.bar_working_41_up = hash_working_41_up.values
    end
  end

  def rali_years_statistical_analysis
    @rali_years_5_below = Employee.where(rali_years: 0..5).count
    @rali_years_6 = Employee.where(rali_years: 6..10).count
    @rali_years_11 = Employee.where(rali_years: 11..15).count
    @rali_years_16 = Employee.where(rali_years: 16..20).count
    @rali_years_21 = Employee.where(rali_years: 21..25).count
    @rali_years_26 = Employee.where(rali_years: 26..30).count
    @rali_years_31 = Employee.where(rali_years: 31..35).count
    @rali_years_36_up = Employee.where(rali_years: 36..100).count

    gon.rali_years_5_below = @rali_years_5_below
    gon.rali_years_6 = @rali_years_6
    gon.rali_years_11 = @rali_years_11
    gon.rali_years_16 = @rali_years_16
    gon.rali_years_21 = @rali_years_21
    gon.rali_years_26 = @rali_years_26
    gon.rali_years_31 = @rali_years_31
    gon.rali_years_36_up = @rali_years_36_up

  @workshops = Employee.pluck("workshop").uniq
    loop_hash_rali_5_below = {}
    hash_rali_5_below = {}
    loop_hash_rali_6 = {}
    hash_rali_6 = {}
    loop_hash_rali_11 = {}
    hash_rali_11 = {}
    loop_hash_rali_16 = {}
    hash_rali_16 = {}
    loop_hash_rali_21 = {}
    hash_rali_21 = {}
    loop_hash_rali_26 = {}
    hash_rali_26 = {}
    loop_hash_rali_31 = {}
    hash_rali_31 = {}
    loop_hash_rali_36_up = {}
    hash_rali_36_up = {}

    @rali_5_below_bar = []
    @rali_6_bar = []
    @rali_11_bar = []
    @rali_16_bar = []
    @rali_21_bar = []
    @rali_26_bar = []
    @rali_31_bar = []
    @rali_36_up_bar = []

    @workshops.each do |i|
      emp = Employee.where(workshop: i).count
      a1 = Employee.where(workshop: i, rali_years: 0..5).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_rali_5_below = {i => a}
      hash_rali_5_below[i] = loop_hash_rali_5_below[i]
      @rali_5_below_bar << a1

      b1 = Employee.where(workshop: i, rali_years: 6..10).count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_rali_6 = {i => b}
      hash_rali_6[i] = loop_hash_rali_6[i]
      @rali_6_bar << b1

      c1 = Employee.where(workshop: i, rali_years: 11..15).count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_rali_11 = {i => c}
      hash_rali_11[i] = loop_hash_rali_11[i]
      @rali_11_bar << c1

      d1 = Employee.where(workshop: i, rali_years: 16..20).count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_rali_16 = {i => d}
      hash_rali_16[i] = loop_hash_rali_16[i]
      @rali_16_bar << d1

      e1 = Employee.where(workshop: i, rali_years: 21..25).count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_rali_21 = {i => e}
      hash_rali_21[i] = loop_hash_rali_21[i]
      @rali_21_bar << e1

      f1 = Employee.where(workshop: i, rali_years: 26..30).count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_rali_26 = {i => f}
      hash_rali_26[i] = loop_hash_rali_26[i]
      @rali_26_bar << f1

      g1 = Employee.where(workshop: i, rali_years: 31..35).count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_rali_31 = {i => g}
      hash_rali_31[i] = loop_hash_rali_31[i]
      @rali_31_bar << g1

      h1 = Employee.where(workshop: i, rali_years: 36..100).count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_rali_36_up = {i => h}
      hash_rali_36_up[i] = loop_hash_rali_36_up[i]
      @rali_36_up_bar << h1
    end

    gon.bar_workshop = hash_rali_5_below.keys
    gon.bar_rali_5_below = hash_rali_5_below.values
    gon.bar_rali_6 = hash_rali_6.values
    gon.bar_rali_11 = hash_rali_11.values
    gon.bar_rali_16 = hash_rali_16.values
    gon.bar_rali_21 = hash_rali_21.values
    gon.bar_rali_26 = hash_rali_26.values
    gon.bar_rali_31 = hash_rali_31.values
    gon.bar_rali_36 = hash_rali_36_up.values
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
          @employees = Employee.where(workshop: params[:workshop], age: 0..25)
        when "26-30岁"
          @employees = Employee.where(workshop: params[:workshop], age: 26..30)
        when "31-35岁"
          @employees = Employee.where(workshop: params[:workshop], age: 31..35)
        when "36-40岁"
          @employees = Employee.where(workshop: params[:workshop], age: 36..40)
        when "41-45岁"
          @employees = Employee.where(workshop: params[:workshop], age: 41..45)
        when "46-50岁"
          @employees = Employee.where(workshop: params[:workshop], age: 46..50)
        when "51-55岁"
          @employees = Employee.where(workshop: params[:workshop], age: 51..55)
        when "56岁以上"
          @employees = Employee.where(workshop: params[:workshop], age: 56..60)
        end
      #学历分析条形图
      elsif params[:education].present?
        @employees = Employee.where(workshop: params[:workshop], education_background: params[:education])
      #工龄分析条形图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          @employees = Employee.where(workshop: params[:workshop], working_years: 0..5)
        when "6-10年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 6..10)
        when "11-15年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 11..15)
        when "16-20年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 16..20)
        when "21-25年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 21..25)
        when "26-30年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 26..30)
        when "31-35年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 31..35)
        when "36-40年"
          @employees = Employee.where(workshop: params[:workshop], working_years: 36..40)
        when "41年以上"
          @employees = Employee.where(workshop: params[:workshop], working_years: 41..100)
        end
      #路龄分析条形图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 0..5)
        when "6-10年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 6..10)
        when "11-15年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 11..15)
        when "16-20年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 16..20)
        when "21-25年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 21..25)
        when "26-30年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 26..30)
        when "31-35年"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 31..35)
        when "36年以上"
          @employees = Employee.where(workshop: params[:workshop], rali_years: 36..100)
        end
      end
    ##没有workshop参数则为饼图，以下为饼图数据配置
    else
      #年龄分析饼图
      if params[:age].present?
        case params[:age]
        when "25岁以下"
          @employees = Employee.where(age: 0..25)
        when "26-30岁"
          @employees = Employee.where(age: 26..30)
        when "31-35岁"
          @employees = Employee.where(age: 31..35)
        when "36-40岁"
          @employees = Employee.where(age: 36..40)
        when "41-45岁"
          @employees = Employee.where(age: 41..45)
        when "46-50岁"
          @employees = Employee.where(age: 46..50)
        when "51-55岁"
          @employees = Employee.where(age: 51..55)

        when "56岁以上"
          @employees = Employee.where(age: 56..100)
        end
      #学历分析饼图
      elsif params[:education].present?
        @employees = Employee.where(education_background: params[:education])
      #工龄分析饼图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          @employees = Employee.where(working_years: 0..5)
        when "6-10年"
          @employees = Employee.where(working_years: 6..10)
        when "11-15年"
          @employees = Employee.where(working_years: 11..15)
        when "16-20年"
          @employees = Employee.where(working_years: 16..20)
        when "21-25年"
          @employees = Employee.where(working_years: 21..25)
        when "26-30年"
          @employees = Employee.where(working_years: 26..30)
        when "31-35年"
          @employees = Employee.where(working_years: 31..35)
        when "36-40年"
          @employees = Employee.where(working_years: 36..40)
        when "41年以上"
          @employees = Employee.where(working_years: 41.100)
        end
      #路龄分析饼图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          @employees = Employee.where(rali_years: 0..5)
        when "6-10年"
          @employees = Employee.where(rali_years: 6..10)
        when "11-15年"
          @employees = Employee.where(rali_years: 11..15)
        when "16-20年"
          @employees = Employee.where(rali_years: 16..20)
        when "21-25年"
          @employees = Employee.where(rali_years: 21..25)
        when "26-30年"
          @employees = Employee.where(rali_years: 26..30)
        when "31-35年"
          @employees = Employee.where(rali_years: 31..35)
        when "36年以上"
          @employees = Employee.where(rali_years: 36..100)
        end
      end
    end
  end
###点击图表详情页面数据配置---结束

###组织架构页面数据配置
  def organization_structure
    @workshops = Employee.pluck("workshop").uniq
    if params[:workshop].present?
      @employees = Employee.where(workshop: params[:workshop]).page(params[:page]).per(16)
    elsif params[:group].present?
      @employees = Employee.where(group: params[:group]).page(params[:page]).per(16)
    else
      @employees = Employee.order('id ASC').page(params[:page]).per(16)
    end
  end


end
