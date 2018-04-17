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

  def statistical_analysis
  	@age_25_below = Employee.where(age: 0..25).count
    @age_25 = Employee.where(age: 25..30).count
    @age_30 = Employee.where(age: 30..35).count
    @age_35 = Employee.where(age: 35..40).count
    @age_40 = Employee.where(age: 40..45).count
    @age_45 = Employee.where(age: 45..50).count
    @age_50 = Employee.where(age: 50..55).count
    @age_55 = Employee.where(age: 55..60).count

    age_count = {}
    age_count = {
      "25岁以下" => @age_25_below, 
      "25-30岁" => @age_25, 
      "30-35岁" => @age_30, 
      "35-40岁" => @age_35, 
      "40-45岁" => @age_40, 
      "45-50岁" => @age_45, 
      "50-55岁" => @age_50, 
      "55-60岁" => @age_55
    }
    
    gon.twenty_five_below = {name: "25岁以下", value: age_count["25岁以下"]}
    gon.twenty_five = {name: "25-30岁", value: age_count["25-30岁"]}
    gon.thirty = {name: "30-35岁", value: age_count["30-35岁"]}
    gon.thirty_five = {name: "35-40岁", value: age_count["35-40岁"]}
    gon.forty = {name: "40-45岁", value: age_count["40-45岁"]}
    gon.forty_five = {name: "45-50岁", value: age_count["45-50岁"]}
    gon.fifty = {name: "50-55岁", value: age_count["50-55岁"]}
    gon.fifty_five = {name: "55-60岁", value: age_count["55-60岁"]}
  
  end

  def import
    Employee.import(params[:file])
    redirect_to employees_path
  end

end
