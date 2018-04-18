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

  def organization_structure
  	
  end

 ### 统计分析页面的图表数据配置---开始
  def statistical_analysis
    # 年龄分析-饼图数据配置---开始

    ## 把各个年龄段的人数捞出，赋值给对应的实例变量
  	@age_25_below = Employee.where(age: 0..25).count
    @age_25 = Employee.where(age: 25..30).count
    @age_30 = Employee.where(age: 30..35).count
    @age_35 = Employee.where(age: 35..40).count
    @age_40 = Employee.where(age: 40..45).count
    @age_45 = Employee.where(age: 45..50).count
    @age_50 = Employee.where(age: 50..55).count
    @age_55 = Employee.where(age: 55..60).count
    
    # 使用'gon'这个gem的方法，将数据以hash方式赋值给对应的变量
    gon.twenty_five_below = @age_25_below
    gon.twenty_five = @age_25
    gon.thirty =  @age_30
    gon.thirty_five =  @age_35
    gon.forty =  @age_40
    gon.forty_five = @age_45
    gon.fifty = @age_50
    gon.fifty_five = @age_55
   
    ## 年龄分析-饼图数据配置---结束
  
  end
  ### 统计分析页面的图表数据配置---结束

  def import
    Employee.import(params[:file])
    redirect_to employees_path
  end

end
