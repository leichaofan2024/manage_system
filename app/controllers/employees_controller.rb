class EmployeesController < ApplicationController


  def index
    @employees = Employee.all
  end

  def import
    Employee.import(params[:file])
    redirect_to employees_path
  end
end
