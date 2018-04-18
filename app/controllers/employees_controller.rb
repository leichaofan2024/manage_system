class EmployeesController < ApplicationController

  def index
    @employees = Employee.page(params[:page])
  end

  def import_table
    Employee.import_table(params[:file])
    redirect_to employees_path
  end

  def search
    @employees = Employee.search(params[:q]).page(params[:page]).records
    render action: "index"
  end

end
