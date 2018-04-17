class EmployeesController < ApplicationController

  def index
    @employees = Employee.all
  end

  def import_table
    Employee.import_table(params[:file])
    redirect_to employees_path
  end

  def search
    @employees = Employee.search(params[:q]).records
    render action: "index"
  end

end
