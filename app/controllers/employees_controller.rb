class EmployeesController < ApplicationController
  layout 'home'
  before_action :validate_search_key, only: [:search]

  # def insert_attendance_cate
  #  hash = {}
  #  a=["日勤","日夜","轮夜","加班","病","事","年","休养","婚","产","育儿","陪产","差","丧","探亲","搬家","培训","旷","工伤"]
  #  b=["日勤","日勤夜班","轮流夜班","节日加班","病假","事假","年休假","年休假（健康休养）","婚假","产假","育儿假","陪产假","出差","丧假","探亲假","搬家假","入学培训","旷工","工伤假"]
  #  n=0
  #  ("a".."s").each do |i|
  #    hash[i] = [a[n], b[n]]
  #    n+=1
  #  end

  #  hash.each do |m|
  #    p = m[1]
  #      VacationCategory.create(:vacation_code => m[0], :vacation_shortening => p[0], :vacation_name => p[1] )
  #  end
  # end

  # def update_holiday_information
  #   a = ["全部职工","干部","工人","其中：主要工种","接触网工","电力工","轨道车司机"]
  #   a.each do |i|
  #     AnnualHolidayWorkType.create(:work_type => i)
  #   end
  # end

  def index
    if (current_user.has_role? :leaderadmin) || (current_user.has_role? :superadmin) || (current_user.has_role? :empadmin) || (current_user.has_role? :attendance_admin) || (current_user.has_role? :limitadmin) || (current_user.has_role? :awardadmin)
      @employees = Employee.current.order('id ASC').page(params[:page]).per(15)
    elsif current_user.has_role? :workshopadmin
      workshop_id = Workshop.find_by(:name => current_user.name).id
      @employees = Employee.current.where(:workshop => workshop_id).page(params[:page]).per(15)
      @workshop = Workshop.find_by(:name => current_user.name)
			@groups = @workshop.groups
      if params[:group].present?
        @employees = Employee.where(:workshop => @workshop.id, :group => params[:group]).page(params[:page]).per(15)
      end
    elsif (current_user.has_role? :organsadmin) || (current_user.has_role? :wgadmin)
      group_id = Group.find_by(:name => current_user.name).id
      @employees = Employee.current.where(:group => group_id).page(params[:page]).per(15)
    else
      group_name = current_user.name.split("-")[1]
      group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
      @employees = Employee.current.where(:workshop => group.workshop_id,:group => group.id).page(params[:page])
    end
    #下载表格配置
    if params[:employees] == "全部"
      @export_employees = Employee.all
    else
      @export_employees = Employee.where(id: params[:employees])
    end
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def new
    @employee = Employee.new
    workshop = Workshop.pluck("name")
      @group = [["--选择省份--"]]
      workshop.each do |name|
        @group << Group.where(:workshop_id => Workshop.find_by(:name => name).id).pluck("name","id")
      end
      gon.group_name = @group
  end

  def create
    if (!Workshop.find_by("id = ?", params[:employee][:workshop]).present?) or (!Group.find_by("id = ?", params[:employee][:group]).present?)
      flash[:alert] = "您填写的车间或班组不存在"
      redirect_to new_employee_path
    else
      @employee = Employee.new(employee_params)
      @employee.update(:workshop => params[:employee][:workshop], :group => params[:employee][:group])
      @employee.birth_year = @employee.birth_date[0..3]
      @employee.age = Time.now.year - @employee.birth_year.to_i
      working_years_transfer = (Time.now - @employee.working_time.to_datetime)/60/60/24/365
      rali_years_transfer = (Time.now - @employee.railway_time.to_datetime)/60/60/24/365
      @employee.working_years = working_years_transfer.to_i
      @employee.rali_years = rali_years_transfer.to_i
      Attendance.create(employee_id: @employee.id, year: Time.now.year, month: Time.now.month)
      if @employee.save
        flash[:notice] = "创建成功"
        redirect_to employee_path(@employee)
      else
        flash[:alert] = "创建失败"
        render :new
      end
    end

  end

  def edit
    @employee = Employee.current.find(params[:id])
    workshop = Workshop.pluck("name")
    @group = []
    workshop.each do |name|
      @group << Group.where(:workshop_id => Workshop.find_by(:name => name).id).pluck("name","id")
    end
    gon.group_name = @group
  end

  def update
    @employee = Employee.current.find(params[:id])
    @employee.update(employee_params)
    @employee.birth_year = @employee.birth_date[0..3]
    @employee.age = Time.now.year - @employee.birth_year.to_i
    working_years_transfer = (Time.now - @employee.working_time.to_datetime)/60/60/24/365
    rali_years_transfer = (Time.now - @employee.railway_time.to_datetime)/60/60/24/365
    @employee.working_years = working_years_transfer.to_i
    @employee.rali_years = rali_years_transfer.to_i
    if @employee.save!
      flash[:notice] = "更新信息成功"
      redirect_to employee_path(params[:id])
    else
      flash[:alert] = "更新失败"
      redirect_to employee_path(params[:id])
    end
  end

  def show
    @employee = Employee.find(params[:id])
  end

 #上传表格
  def import_table
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      Employee.import_table(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to employees_path
  end

  def filter
    if current_user.has_role? :empadmin or current_user.has_role? :attendance_admin or current_user.has_role? :superadmin or current_user.has_role? :leaderadmin
      condition = ".current.where(company_name: '北京供电段'"
    elsif current_user.has_role? :workshopadmin
      condition = ".current.where(workshop: Workshop.find_by(name: current_user.name).id"
    elsif current_user.has_role? :organsadmin
      condition = ".current.where(group: Group.find_by(name: current_user.name).id"
    elsif current_user.has_role? :groupadmin
      condition = ".current.where(group: Group.find_by(name: current_user.name.split('-')[1]).id"
    end
    if params[:duan].present?
      condition = ".current.where(company_name: '北京供电段'"
    end
    if params[:workshop].present?
      condition += ", workshop: #{params[:workshop]}"
    end
    if params[:group].present?
      condition += ", group: #{params[:group]}"
    end
    if params[:sex].present?
      condition += ", sex: '#{params[:sex]}'"
    end
    if params[:duty].present?
      condition += ", duty: '#{params[:duty]}'"
    end
    if params[:work_type].present?
      condition += ", work_type: '#{params[:work_type]}'"
    end
    if params[:filter_type].present?
      case params[:filter_type]
      when "年龄"
        condition += ", age: #{params[:start_time]}..#{params[:end_time]}"
      when "工龄"
        condition += ", working_years: #{params[:start_time]}..#{params[:end_time]}"
      when "路龄"
        condition += ", rali_years: #{params[:start_time]}..#{params[:end_time]}"
      end
    end
    condition += ").page(params[:page]).per(15)"
    @employees = eval("Employee#{condition}")
    @sex = params[:sex]
    @duty = params[:duty]
    @work_type = params[:work_type]
    @filter_type = params[:filter_type]
    @workshop = params[:workshop]
    @group = params[:group]
    render action: "index"
  end
  #搜索和筛选--结束

  #一键更新
  def update_employee_info
    @employees = Employee.current.all
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
    @data_source = params[:data_source]
    if params[:data_source] == "干部"
      employees = Employee.current.cadre
    elsif params[:data_source] == "工人"
      employees = Employee.current.worker
    else
      employees = Employee.current
    end
    @age_25_below = employees.where(age: 0..25).count
    @age_26 = employees.where(age: 26..30).count
    @age_31 = employees.where(age: 31..35).count
    @age_36 = employees.where(age: 36..40).count
    @age_41 = employees.where(age: 41..45).count
    @age_46 = employees.where(age: 46..50).count
    @age_51 = employees.where(age: 51..55).count
    @age_56_up = employees.where(age: 56..100).count
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
    @workshops = employees.pluck("workshop").uniq
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
        emp = employees.where(workshop: i).count
        #把各年龄段在各车间的人数存成变量
        a1 = employees.where(workshop: i, age: 0..25).count
        #算出各年龄段人数占车间总人数的比重
        a = (a1.to_f)/(emp.to_f)
        #将每一次的计算结果存成"车间 => 百分比"的hash
        loop_hash_25_below = {i => a}
        #将每一次的hash结果存到最终的hash里，供之后使用
        hash_25_below[i] = loop_hash_25_below[i]
        @age_25_below_bar << a1

        b1 = employees.where(workshop: i, age: 26..30).count
        b = (b1.to_f)/(emp.to_f)
        loop_hash_26 = {i => b}
        hash_26[i] = loop_hash_26[i]
        @age_26_bar << b1

        c1 = employees.where(workshop: i, age: 31..35).count
        c = (c1.to_f)/(emp.to_f)
        loop_hash_31 = {i => c}
        hash_31[i] = loop_hash_31[i]
        @age_31_bar << c1

        d1 = employees.where(workshop: i, age: 36..40).count
        d = (d1.to_f)/(emp.to_f)
        loop_hash_36 = {i => d}
        hash_36[i] = loop_hash_36[i]
        @age_36_bar << d1

        e1 = employees.where(workshop: i, age: 41..45).count
        e = (e1.to_f)/(emp.to_f)
        loop_hash_41 = {i => e}
        hash_41[i] = loop_hash_41[i]
        @age_41_bar << e1

        f1 = employees.where(workshop: i, age: 46..50).count
        f = (f1.to_f)/(emp.to_f)
        loop_hash_46 = {i => f}
        hash_46[i] = loop_hash_46[i]
        @age_46_bar << f1

        g1 = employees.where(workshop: i, age: 51..55).count
        g = (g1.to_f)/(emp.to_f)
        loop_hash_51 = {i => g}
        hash_51[i] = loop_hash_51[i]
        @age_51_bar << g1

        h1 = employees.where(workshop: i, age: 56..70).count
        h = (h1.to_f)/(emp.to_f)
        loop_hash_56_up = {i => h}
        hash_56_up[i] = loop_hash_56_up[i]
        @age_56_up_bar << h1
      end
      #生成每个年龄段的【车间-人数】hash---结束

    #将以上算出最终hash的keys赋值给对应的变量，作为条形图的坐标轴信息
    gon.bar_workshop = Workshop.pluck("name").uniq
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
    @data_source = params[:data_source]
    if params[:data_source] == "干部"
      employees = Employee.current.cadre
    elsif params[:data_source] == "工人"
      employees = Employee.current.worker
    else
      employees = Employee.current
    end
    @junior_high_school = employees.where(education_background: ["初中"]).count
    @primary_school = employees.where(education_background: ["小学"]).count
    @senior_high_school = employees.where(education_background: "高中").count
    @technical_school = employees.where(education_background: "技校").count
    @secondary_school = employees.where(education_background: "中专").count
    @university_specialties = employees.where(education_background: "大学专科").count
    @undergraduate = employees.where(education_background: "大学本科").count
    @postgraduate = employees.where(education_background: "研究生").count

    gon.junior_high_school = @junior_high_school_below
    gon.senior_high_school = @senior_high_school
    gon.technical_school =  @technical_school
    gon.secondary_school =  @secondary_school
    gon.university_specialties =  @university_specialties
    gon.undergraduate = @undergraduate
    gon.postgraduate = @postgraduate
    gon.primary_school = @primary_school

    @workshops = employees.pluck("workshop").uniq
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
      emp = employees.where(workshop: i).count
      a1 = employees.where(workshop: i, education_background: "初中").count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_junior_high_school = {i => a}
      hash_junior_high_school[i] = loop_hash_junior_high_school[i]
      @junior_high_school_bar << a1

      b1 = employees.where(workshop: i, education_background: "小学").count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_primary_school = {i => b}
      hash_primary_school[i] = loop_hash_primary_school[i]
      @primary_school_bar << b1

      c1 = employees.where(workshop: i, education_background: "高中").count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_senior_high_school = {i => c}
      hash_senior_high_school[i] = loop_hash_senior_high_school[i]
      @senior_high_school_bar << c1

      d1 = employees.where(workshop: i, education_background: "技校").count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_technical_school = {i => d}
      hash_technical_school[i] = loop_hash_technical_school[i]
      @technical_school_bar << d1

      e1 = employees.where(workshop: i, education_background: "中专").count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_secondary_school = {i => e}
      hash_secondary_school[i] = loop_hash_secondary_school[i]
      @secondary_school_bar << e1

      f1 = employees.where(workshop: i, education_background: "大学专科").count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_university_specialties = {i => f}
      hash_university_specialties[i] = loop_hash_university_specialties[i]
      @university_specialties_bar << f1

      g1 = employees.where(workshop: i, education_background: "大学本科").count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_undergraduate = {i => g}
      hash_undergraduate[i] = loop_hash_undergraduate[i]
      @undergraduate_bar << g1

      h1 = employees.where(workshop: i, education_background: "研究生").count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_postgraduate = {i => h}
      hash_postgraduate[i] = loop_hash_postgraduate[i]
      @postgraduate_bar << h1
    end
    gon.bar_workshop = Workshop.pluck("name").uniq
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
    @data_source = params[:data_source]
    if params[:data_source] == "干部"
      employees = Employee.current.cadre
    elsif params[:data_source] == "工人"
      employees = Employee.current.worker
    else
      employees = Employee.current
    end

    @working_years_5_below = employees.where(working_years: 0..5).count
    @working_years_6 = employees.where(working_years: 6..10).count
    @working_years_11 = employees.where(working_years: 11..15).count
    @working_years_16 = employees.where(working_years: 16..20).count
    @working_years_21 = employees.where(working_years: 21..25).count
    @working_years_26 = employees.where(working_years: 26..30).count
    @working_years_31 = employees.where(working_years: 31..35).count
    @working_years_36 = employees.where(working_years: 36..40).count
    @working_years_41_up = employees.where(working_years: 41..100).count

    gon.working_years_5_below = @working_years_5_below
    gon.working_years_6 = @working_years_6
    gon.working_years_11 = @working_years_11
    gon.working_years_16 = @working_years_16
    gon.working_years_21 = @working_years_21
    gon.working_years_26 = @working_years_26
    gon.working_years_31 = @working_years_31
    gon.working_years_36 = @working_years_36
    gon.working_years_41_up = @working_years_41_up

    @workshops = employees.pluck("workshop").uniq
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
      emp = employees.where(workshop: i).count
      a1 = employees.where(workshop: i, working_years: 0..5).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_working_5_below = {i => a}
      hash_working_5_below[i] = loop_hash_working_5_below[i]
      @working_5_below_bar << a1

      b1 = employees.where(workshop: i, working_years: 6..10).count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_working_6 = {i => b}
      hash_working_6[i] = loop_hash_working_6[i]
      @working_6_bar << b1

      c1 = employees.where(workshop: i, working_years: 11..15).count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_working_11 = {i => c}
      hash_working_11[i] = loop_hash_working_11[i]
      @working_11_bar << c1

      d1 = employees.where(workshop: i, working_years: 16..20).count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_working_16 = {i => d}
      hash_working_16[i] = loop_hash_working_16[i]
      @working_16_bar << d1

      e1 = employees.where(workshop: i, working_years: 21..25).count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_working_21 = {i => e}
      hash_working_21[i] = loop_hash_working_21[i]
      @working_21_bar << e1

      f1 = employees.where(workshop: i, working_years: 26..30).count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_working_26 = {i => f}
      hash_working_26[i] = loop_hash_working_26[i]
      @working_26_bar << f1

      g1 = employees.where(workshop: i, working_years: 31..35).count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_working_31 = {i => g}
      hash_working_31[i] = loop_hash_working_31[i]
      @working_31_bar << g1

      h1 = employees.where(workshop: i, working_years: 36..40).count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_working_36 = {i => h}
      hash_working_36[i] = loop_hash_working_36[i]
      @working_36_bar << h1

      j1 = employees.where(workshop: i, working_years: 41..100).count
      j = (j1.to_f)/(emp.to_f)
      loop_hash_working_41_up = {i => j}
      hash_working_41_up[i] = loop_hash_working_41_up[i]
      @working_41_up_bar << j1

      gon.bar_workshop = Workshop.pluck("name").uniq
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

  def worktype_statistical_analysis
    @workshops = Workshop.all
    @gaoJiGong = Employee.current.where(work_type: ["高级工（１）", "高级工（２）"]).count
    @zhongJiGong = Employee.current.where(work_type: ["中级工（１）", "中级工（２）", "中级工（３）"]).count
    @chuJiGong = Employee.current.where(work_type: ["初级工（１）", "初级工（２）"]).count
    @jiShi = Employee.current.where(work_type: "技师").count
    @gaoJiJiShi = Employee.current.where(work_type: "高级技师").count
    @weiJianDing = Employee.current.where(work_type: ["熟练制工人", "学徒工"]).count

    gon.gaoJiGong = @gaoJiGong
    gon.zhongJiGong = @zhongJiGong
    gon.chuJiGong = @chuJiGong
    gon.jiShi = @jiShi
    gon.gaoJiJiShi = @gaoJiJiShi
    gon.weiJianDing = @weiJianDing

    @workshops = Employee.current.pluck("workshop").uniq
    loop_hash_gaoJiGong = {}
    hash_gaoJiGong = {}
    loog_hash_zhongJiGong = {}
    hash_zhongJiGong = {}
    loog_hash_chuJiGong = {}
    hash_chuJiGong = {}
    loog_hash_jiShi = {}
    hash_jiShi = {}
    loog_hash_gaoJiJiShi = {}
    hash_gaoJiJiShi = {}
    loog_hash_weiJianDing = {}
    hash_weiJianDing = {}

    @table_gaoJiGong = []
    @table_zhongJiGong = []
    @table_chuJiGong = []
    @table_jiShi = []
    @table_gaoJiJiShi = []
    @table_weiJianDing = []

    @workshops.each do |i|
      emp = Employee.current.where(workshop: i, :work_type => ["高级工（１）", "高级工（２）", "中级工（１）", "中级工（２）", "中级工（３）", "初级工（１）", "初级工（２）", "技师", "高级技师", "熟练制工人", "学徒工"]).count
      a1 = Employee.current.where(workshop: i, :work_type => ["高级工（１）", "高级工（２）"]).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_gaoJiGong = {i => a}
      hash_gaoJiGong[i] = loop_hash_gaoJiGong[i]
      @table_gaoJiGong << a1

      b1 = Employee.current.where(workshop: i, :work_type => ["中级工（１）", "中级工（２）", "中级工（３）"]).count
      b = (b1.to_f)/(emp.to_f)
      loog_hash_zhongJiGong = {i => b}
      hash_zhongJiGong[i] = loog_hash_zhongJiGong[i]
      @table_zhongJiGong << b1

      c1 = Employee.current.where(workshop: i, :work_type => ["初级工（１）", "初级工（２）"]).count
      c = (c1.to_f)/(emp.to_f)
      loog_hash_chuJiGong = {i => c}
      hash_chuJiGong[i] = loog_hash_chuJiGong[i]
      @table_chuJiGong << c1

      d1 = Employee.current.where(workshop: i, :work_type => "技师").count
      d = (d1.to_f)/(emp.to_f)
      loog_hash_jiShi = {i => d}
      hash_jiShi[i] = loog_hash_jiShi[i]
      @table_jiShi << d1

      e1 = Employee.current.where(workshop: i, :work_type => "高级技师").count
      e = (e1.to_f)/(emp.to_f)
      loog_hash_gaoJiJiShi = {i => e}
      hash_gaoJiJiShi[i] = loog_hash_gaoJiJiShi[i]
      @table_gaoJiJiShi << e1

      f1 = Employee.current.where(workshop: i, :work_type => ["熟练制工人", "学徒工"]).count
      f = (f1.to_f)/(emp.to_f)
      loog_hash_weiJianDing = {i => f}
      hash_weiJianDing[i] = loog_hash_weiJianDing[i]
      @table_weiJianDing << f1

      gon.bar_workshop = Workshop.pluck("name").uniq
      gon.bar_gaoJiGong = hash_gaoJiGong.values
      gon.bar_zhongJiGong = hash_zhongJiGong.values
      gon.bar_chuJiGong = hash_chuJiGong.values
      gon.bar_jiShi = hash_jiShi.values
      gon.bar_gaoJiJiShi = hash_gaoJiJiShi.values
      gon.bar_weiJianDing = hash_weiJianDing.values
    end
  end

  def rali_years_statistical_analysis
    @data_source = params[:data_source]
    if params[:data_source] == "干部"
      employees = Employee.current.cadre
    elsif params[:data_source] == "工人"
      employees = Employee.current.worker
    else
      employees = Employee.current
    end
    @rali_years_5_below = employees.where(rali_years: 0..5).count
    @rali_years_6 = employees.where(rali_years: 6..10).count
    @rali_years_11 = employees.where(rali_years: 11..15).count
    @rali_years_16 = employees.where(rali_years: 16..20).count
    @rali_years_21 = employees.where(rali_years: 21..25).count
    @rali_years_26 = employees.where(rali_years: 26..30).count
    @rali_years_31 = employees.where(rali_years: 31..35).count
    @rali_years_36_up = employees.where(rali_years: 36..100).count

    gon.rali_years_5_below = @rali_years_5_below
    gon.rali_years_6 = @rali_years_6
    gon.rali_years_11 = @rali_years_11
    gon.rali_years_16 = @rali_years_16
    gon.rali_years_21 = @rali_years_21
    gon.rali_years_26 = @rali_years_26
    gon.rali_years_31 = @rali_years_31
    gon.rali_years_36_up = @rali_years_36_up

  @workshops = employees.pluck("workshop").uniq
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
      emp = employees.where(workshop: i).count
      a1 = employees.where(workshop: i, rali_years: 0..5).count
      a = (a1.to_f)/(emp.to_f)
      loop_hash_rali_5_below = {i => a}
      hash_rali_5_below[i] = loop_hash_rali_5_below[i]
      @rali_5_below_bar << a1

      b1 = employees.where(workshop: i, rali_years: 6..10).count
      b = (b1.to_f)/(emp.to_f)
      loop_hash_rali_6 = {i => b}
      hash_rali_6[i] = loop_hash_rali_6[i]
      @rali_6_bar << b1

      c1 = employees.where(workshop: i, rali_years: 11..15).count
      c = (c1.to_f)/(emp.to_f)
      loop_hash_rali_11 = {i => c}
      hash_rali_11[i] = loop_hash_rali_11[i]
      @rali_11_bar << c1

      d1 = employees.where(workshop: i, rali_years: 16..20).count
      d = (d1.to_f)/(emp.to_f)
      loop_hash_rali_16 = {i => d}
      hash_rali_16[i] = loop_hash_rali_16[i]
      @rali_16_bar << d1

      e1 = employees.where(workshop: i, rali_years: 21..25).count
      e = (e1.to_f)/(emp.to_f)
      loop_hash_rali_21 = {i => e}
      hash_rali_21[i] = loop_hash_rali_21[i]
      @rali_21_bar << e1

      f1 = employees.where(workshop: i, rali_years: 26..30).count
      f = (f1.to_f)/(emp.to_f)
      loop_hash_rali_26 = {i => f}
      hash_rali_26[i] = loop_hash_rali_26[i]
      @rali_26_bar << f1

      g1 = employees.where(workshop: i, rali_years: 31..35).count
      g = (g1.to_f)/(emp.to_f)
      loop_hash_rali_31 = {i => g}
      hash_rali_31[i] = loop_hash_rali_31[i]
      @rali_31_bar << g1

      h1 = employees.where(workshop: i, rali_years: 36..100).count
      h = (h1.to_f)/(emp.to_f)
      loop_hash_rali_36_up = {i => h}
      hash_rali_36_up[i] = loop_hash_rali_36_up[i]
      @rali_36_up_bar << h1
    end

    gon.bar_workshop = Workshop.pluck("name").uniq
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
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 0..25)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 0..25)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 0..25)
          end
        when "26-30岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 26..30)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 26..30)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 26..30)
          end
        when "31-35岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 31..35)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 31..35)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 31..35)
          end
        when "36-40岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 36..40)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 36..40)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 36..40)
          end
        when "41-45岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 41..45)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 41..45)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 41..45)
          end
        when "46-50岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 46..50)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 46..50)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 46..50)
          end
        when "51-55岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 51..55)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 51..55)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 51..55)
          end
        when "56岁以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], age: 56..60)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], age: 56..60)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], age: 56..60)
          end
        end
      #学历分析条形图
      elsif params[:education].present?
        case params[:data_source]
        when "全员"
          @employees = Employee.current.where(workshop: params[:workshop], education_background: params[:education])
        when "干部"
          @employees = Employee.current.cadre.where(workshop: params[:workshop], education_background: params[:education])
        when "工人"
          @employees = Employee.current.worker.where(workshop: params[:workshop], education_background: params[:education])
        end
      #工龄分析条形图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 0..5)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 0..5)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 0..5)
          end
        when "6-10年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 6..10)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 6..10)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 6..10)
          end
        when "11-15年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 11..15)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 11..15)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 11..15)
          end
        when "16-20年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 16..20)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 16..20)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 16..20)
          end
        when "21-25年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 21..25)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 21..25)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 21..25)
          end
        when "26-30年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 26..30)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 26..30)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 26..30)
          end
        when "31-35年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 31..35)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 31..35)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 31..35)
          end
        when "36-40年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 36..40)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 36..40)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 36..40)
          end
        when "41年以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], working_years: 41..100)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], working_years: 41..100)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], working_years: 41..100)
          end
        end
      #路龄分析条形图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 0..5)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 0..5)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 0..5)
          end
        when "6-10年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 6..10)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 6..10)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 6..10)
          end
        when "11-15年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 11..15)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 11..15)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 11..15)
          end
        when "16-20年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 16..20)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 16..20)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 16..20)
          end
        when "21-25年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 21..25)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 21..25)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 21..25)
          end
        when "26-30年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 26..30)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 26..30)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 26..30)
          end
        when "31-35年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 31..35)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 31..35)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 31..35)
          end
        when "36年以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(workshop: params[:workshop], rali_years: 36..100)
          when "干部"
            @employees = Employee.current.cadre.where(workshop: params[:workshop], rali_years: 36..100)
          when "工人"
            @employees = Employee.current.worker.where(workshop: params[:workshop], rali_years: 36..100)
          end
        end
      elsif params[:work_type].present?
        a = params[:work_type].to_s.gsub(/\p{Han}+/u).first
        if a != "技师"
          @employees = Employee.current.where("work_type LIKE ?", ['%', "#{a}", '%'].join).where(workshop: params[:workshop])
        else
          @employees = Employee.current.where(workshop: params[:workshop], :work_type => params[:work_type])
        end
      end
    ##没有workshop参数则为饼图，以下为饼图数据配置
    else
      #年龄分析饼图
      if params[:age].present?
        case params[:age]
        when "25岁以下"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 0..25).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 0..25).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 0..25).page(params[:page]).per(20)
          end
        when "26-30岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 26..30).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 26..30).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 26..30).page(params[:page]).per(20)
          end
        when "31-35岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 31..35).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 31..35).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 31..35).page(params[:page]).per(20)
          end
        when "36-40岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 36..40).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 36..40).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 36..40).page(params[:page]).per(20)
          end
        when "41-45岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 41..45).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 41..45).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 41..45).page(params[:page]).per(20)
          end
        when "46-50岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 46..50).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 46..50).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 46..50).page(params[:page]).per(20)
          end
        when "51-55岁"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 51..55).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 51..55).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 51..55).page(params[:page]).per(20)
          end
        when "56岁以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(age: 56..100).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(age: 56..100).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(age: 56..100).page(params[:page]).per(20)
          end
        end
      #学历分析饼图
      elsif params[:education].present?
        case params[:data_source]
        when "全员"
          @employees = Employee.current.where(education_background: params[:education]).page(params[:page]).per(20)
        when "干部"
          @employees = Employee.current.cadre.where(education_background: params[:education]).page(params[:page]).per(20)
        when "工人"
          @employees = Employee.current.worker.where(education_background: params[:education]).page(params[:page]).per(20)
        end
      #工龄分析饼图
      elsif params[:working_years].present?
        case params[:working_years]
        when "5年以下"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 0..5).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 0..5).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 0..5).page(params[:page]).per(20)
          end
        when "6-10年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 6..10).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 6..10).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 6..10).page(params[:page]).per(20)
          end
        when "11-15年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 11..15).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 11..15).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 11..15).page(params[:page]).per(20)
          end
        when "16-20年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 16..20).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 16..20).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 16..20).page(params[:page]).per(20)
          end
        when "21-25年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 21..25).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 21..25).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 21..25).page(params[:page]).per(20)
          end
        when "26-30年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 26..30).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 26..30).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 26..30).page(params[:page]).per(20)
          end
        when "31-35年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 31..35).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 31..35).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 31..35).page(params[:page]).per(20)
          end
        when "36-40年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 36..40).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 36..40).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 36..40).page(params[:page]).per(20)
          end
        when "41年以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(working_years: 41..100).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(working_years: 41..100).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(working_years: 41..100).page(params[:page]).per(20)
          end
        end
      #路龄分析饼图
      elsif params[:rali_years].present?
        case params[:rali_years]
        when "5年以下"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 0..5).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 0..5).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 0..5).page(params[:page]).per(20)
          end
        when "6-10年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 6..10).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 6..10).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 6..10).page(params[:page]).per(20)
          end
        when "11-15年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 11..15).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 11..15).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 11..15).page(params[:page]).per(20)
          end
        when "16-20年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 16..20).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 16..20).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 16..20).page(params[:page]).per(20)
          end
        when "21-25年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 21..25).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 21..25).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 21..25).page(params[:page]).per(20)
          end
        when "26-30年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 26..30).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 26..30).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 26..30).page(params[:page]).per(20)
          end
        when "31-35年"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 31..35).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 31..35).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 31..35).page(params[:page]).per(20)
          end
        when "36年以上"
          case params[:data_source]
          when "全员"
            @employees = Employee.current.where(rali_years: 36..100).page(params[:page]).per(20)
          when "干部"
            @employees = Employee.current.cadre.where(rali_years: 36..100).page(params[:page]).per(20)
          when "工人"
            @employees = Employee.current.worker.where(rali_years: 36..100).page(params[:page]).per(20)
          end
        end
      elsif params[:work_type].present?
        a = params[:work_type].gsub(/\p{Han}+/u).first
        if a != "技师"
          @employees = Employee.current.where("work_type LIKE ?", ['%', "#{a}", '%'].join).page(params[:page]).per(20)
        else
          @employees = Employee.current.where(:work_type => params[:work_type]).page(params[:page]).per(20)
        end
      end
    end
    @export_employees = Employee.where(id: params[:employees])
    respond_to do |format|
      format.html
      format.xls
    end
  end
###点击图表详情页面数据配置---结束

###组织架构页面数据配置
  def organization_structure
    @workshop = params[:workshop]
    @group = params[:group]
    @workshops = Workshop.all
    if params[:workshop].present?
      @employees = Employee.current.where(workshop: params[:workshop]).page(params[:page]).per(16)
    elsif params[:group].present?
      @employees = Employee.current.where(group: params[:group]).page(params[:page]).per(16)
    else
      @employees = Employee.current.order('id ASC').page(params[:page]).per(16)
    end
    if params[:employees] == "全部"
      @export_employees = Employee.all
    else
      @export_employees = Employee.where(id: params[:employees])
    end
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def create_workshop
    workshop = Workshop.find_by(:name => params[:name]) || Workshop.new
    workshop.update(:name => params[:name])
    flash[:notice] = "新增车间成功"
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def create_group
    workshop_id = Workshop.find_by(:name => params[:workshop_name]).id
    if workshop_id.present?
      group = Group.find_by(:name => params[:name]) || Group.new
      group.update(:name => params[:name], :workshop_id => workshop_id)
      flash[:notice] = "新增班组成功"
    else
      flash[:alert] = "该车间名称不存在，请先检查"
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def merge_workshop
    if Workshop.find_by(:name => params[:merge_workshop]).present?
      flash[:notice] = "该车间名称已存在，请换一个试试~"
    else
      workshop = Workshop.create(:name => params[:merge_workshop])
      if !params[:workshops].present?
        flash[:alert] = "请先选择车间再合并"
      else
        params[:workshops].each do |workshop_id|
          Group.where(:workshop_id => params[:workshops]).update(:workshop_id => workshop.id)
          Employee.current.where(:workshop => params[:workshops]).update(:workshop => workshop.id)
          Workshop.where(:id => params[:workshops]).delete_all
        end
        flash[:notice] = "合并车间成功"
      end
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def merge_group
    if !Workshop.find_by(:name => params[:workshop]).present?
      flash[:alert] = "您填写的车间名称不存在，请先增加车间"
    else
      if !params[:groups].present?
        flash[:alert] = "请先选择班组再合并"
      else
        workshop = Workshop.find_by(:name => params[:workshop])
        group = Group.create(:name => params[:merge_group], :workshop_id => workshop.id)
        Employee.current.where(:group => params[:groups]).update(:group => group.id, :workshop => workshop.id)
        Group.where(:id => params[:groups]).delete_all
        flash[:notice] = "合并车间成功"
      end
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def delete_organization
    if params[:workshop].present?
      workshop = Workshop.find(params[:workshop])
      if workshop.groups.blank? && Employee.current.where(:workshop => params[:workshop]).blank?
        workshop.delete
        flash[:notice] = "删除成功"
      else
        flash[:alert] = "本车间下还有班组或人员，不能删除"
      end
    elsif params[:group].present?
      group = Group.find(params[:group])
      if Employee.current.where(:group => params[:group]).blank?
        group.delete
        flash[:notice] = "删除成功"
      else
        flash[:alert] = "本班组下还有人员，不能删除"
      end
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def edit_workshop
    if !params[:workshop].present?
      flash[:alert] = "请先选择一个车间再修改"
    else
      Workshop.find(params[:workshop]).update(:name => params[:workshop_name])
      flash[:notice] = "更新成功"
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def edit_group
    if !Workshop.find_by(:name => params[:workshop_name]).present?
      flash[:alert] = "您填写的车间名称不存在，请先新增哦"
    else
      if !params[:group].present?
        flash[:alert] = "请先选择一个班组再修改"
      else
        Group.find(params[:group]).update(:name => params[:group_name], :workshop_id => Workshop.find_by(:name => params[:workshop_name]).id)
        flash[:notice] = "更新成功"
      end
    end
    redirect_back(fallback_location: organization_structure_employees_path)
  end

  def show_leaving_employee_modal
    @employee = params[:employee]
    @type = params[:type]
    respond_to do |format|
      format.js
    end
  end

  def create_leaving
    if params[:type] == "调离"
      LeavingEmployee.create(:employee_id => params[:employee], :cause => params[:cause], :leaving_type => "调离")
      flash[:notice] = "已将#{Employee.find(params[:employee]).name}调离"
    elsif params[:type] == "调动"
      LeavingEmployee.create(:employee_id => params[:employee], :leaving_type => "调动", :transfer_from_workshop => Employee.find(params[:employee]).workshop, :transfer_from_group => Employee.find(params[:employee]).group, :transfer_to_workshop => Workshop.find_by(:name => params[:workshop]).id, :transfer_to_group => Group.find_by(:name => params[:group]).id)
      Employee.current.find(params[:employee]).update(:workshop => Workshop.find_by(:name => params[:workshop]).id, :group => Group.find_by(:name => params[:group]).id)
      flash[:notice] = "已将#{Employee.find(params[:employee]).name}调动到#{params[:workshop]}车间#{params[:group]}班组"
    elsif params[:type] == "退休"
      LeavingEmployee.create(:employee_id => params[:employee], :cause => params[:cause], :leaving_type => "退休")
      flash[:notice] = "#{Employee.find(params[:employee]).name}已退休"
    end
    redirect_back(fallback_location: employees_path)
  end

  def employee_detail
    @type = params[:type]
    if params[:type] == "调离"
      @employees = LeavingEmployee.where(:leaving_type => "调离").page(params[:page]).per(15)
    elsif params[:type] == "调动"
      @employees = LeavingEmployee.where(:leaving_type => "调动").page(params[:page]).per(15)
    elsif params[:type] == "退休"
      @employees = LeavingEmployee.where(:leaving_type => "退休").page(params[:page]).per(15)
    elsif params[:default] == "男"
      @employees = Employee.current.where(:sex => '男').page(params[:page]).per(15)
    elsif params[:default] == "女"
      @employees = Employee.current.where(:sex => '女').page(params[:page]).per(15)
    else
      if params[:aa][:duty].present?
        condition += ", duty: '#{params[:aa][:duty]}'"
      end
      if params[:aa][:work_type].present?
        condition += ", work_type: '#{params[:aa][:work_type]}'"
      end
      if params[:aa][:sex].present?
        condition += ", sex: '#{params[:aa][:sex]}'"
      end
      if params[:aa][:filter_type].present?
        case params[:aa][:filter_type]
        when "年龄"
          condition += ", age: #{params[:aa][:start_time]}..#{params[:aa][:end_time]}"
        when "工龄"
          condition += ", working_years: #{params[:aa][:start_time]}..#{params[:aa][:end_time]}"
        when "路龄"
          condition += ", rali_years: #{params[:aa][:start_time]}..#{params[:aa][:end_time]}"
        end
      end
      condition += ").page(params[:page]).per(15)"
      @employees = eval("Employee#{condition}")
    end
  end

  ### 综合分析
  def compsite_statistical_analysis
    @age_25_below = Employee.current.where(age: 0..25).count
    @age_26 = Employee.current.where(age: 26..30).count
    @age_31 = Employee.current.where(age: 31..35).count
    @age_36 = Employee.current.where(age: 36..40).count
    @age_41 = Employee.current.where(age: 41..45).count
    @age_46 = Employee.current.where(age: 46..50).count
    @age_51 = Employee.current.where(age: 51..55).count
    @age_56_up = Employee.current.where(age: 56..100).count

    @work_types = Employee.current.pluck(:work_type).uniq
    @workshops = Employee.current.pluck(:workshop).uniq
    @groups = Employee.current.pluck(:group).uniq
    @education_background = Employee.current.pluck(:education_background).uniq
    @skilledness_authenticate = Employee.current.pluck(:skilledness_authenticate).uniq
  end

  def search
    if @query_string.present?
      @employees = search_params
    end
  end

  private

    def employee_params
      params.require(:employee).permit(:name, :sal_number, :job_number, :record_number, :workshop, :group, :name, :sex, :birth_date, :birth_year, :age, :nation, :native_place, :political_role, :political_party_date, :working_time, :railway_time, :entry_time, :duty, :employment_period, :part_time, :grade, :promotion_leader_time, :technique_duty,
       :hold_technique_time, :work_type, :job_foreman, :contract_station, :three_one, :people_source, :people_category, :education_background, :graduation_school, :school_sort, :major, :where_place, :employment_form, :contract_period, :conclude_contract_time, :record_saler, :skilledness_saler, :station_saler, :seniority_saler, :skilledness_authenticate, :treatment, :station_rank, :skilledness_rank, :station_now, :station_now_time, :retire_condition,
       :marriage_status, :separate_status, :visit_family, :registered_residence, :family_address, :comment, :identity_card_number, :employee_card_number, :trade_code, :produce_group, :saler_item, :other_saler, :comment_data, :graduation_time, :position, :group_category, :job_foreman_category, :job_foreman_duty, :phone_number, :avatar, :station_rank, :skilledness_rank, :entry_time, :company_name)
    end

  protected

    def validate_search_key
      @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    end

    def search_params
      if current_user.has_role? :organsadmin
        group_id = Group.find_by(:name => current_user.name).id
        @employees = Employee.current.where(:group => group_id).ransack({ :name_or_identity_card_number_or_sal_number_cont => @query_string}).result(distinct: true)
      elsif (current_user.has_role? :superadmin) || (current_user.has_role? :empadmin) || (current_user.has_role? :attendance_admin) || (current_user.has_role? :limitadmin) || (current_user.has_role? :awardadmin)
        Employee.ransack({ :name_or_identity_card_number_or_sal_number_cont => @query_string}).result(distinct: true)
      elsif current_user.has_role? :workshopadmin
        workshop_id = Workshop.find_by(:name => current_user.name).id
        @employees = Employee.current.where(:workshop => workshop_id).ransack({ :name_or_identity_card_number_or_sal_number_cont => @query_string}).result(distinct: true)
      else
        group_name = current_user.name.split("-")[1]
        group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
        @employees = Employee.current.where(:workshop => group.workshop_id,:group => group.id).ransack({ :name_or_job_number_cont => @query_string}).result(distinct: true)
      end
    end


end
