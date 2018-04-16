class EmployeesController < ApplicationController


  def index
    @employees = Employee.page(params[:page]).per(20)
  end

  def import
    Employee.import(params[:file])
    redirect_to employees_path
  end
end
