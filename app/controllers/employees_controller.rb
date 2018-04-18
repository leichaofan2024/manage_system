class EmployeesController < ApplicationController
  layout 'home'
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

  def update_sal_number
    @employees = Employee.all
    @employees.each do |employee|
      employee.sal_number = '41' + employee.job_number
      employee.save!
    end
    redirect_to employees_path
  end

end
