class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user
  rescue_from Exception, with: :show_errors
  def set_current_user
    RelativeSaler.current_user = current_user
  end


  def required_is_admin
    unless (current_user.has_role? :awardadmin) || (current_user.has_role? :superadmin)
      flash[:alert] = '权限不足，请联系管理员'
      redirect_to root_path
    end
  end

  def required_is_groupadmin
    if current_user.has_role? :groupadmin
      flash[:alert] = '您的权限不足'
      redirect_to root_path
    end
  end

  def employee_name_colums
    @employee_columns = Employee.column_names - ["id","created_at","updated_at","avatar","group_id","workshop_id","name"]
    employee_array = []
    employee_key = []
    @employee_columns.each do |column|
      if column == "workshop"
        employee_array << [column,[Employee.pluck(column).uniq.compact,Employee.pluck(column).uniq.compact.map{|x| Workshop.find_by(id: x).name}]]
      elsif column == "group"
        employee_array << [column,[Employee.pluck(column).uniq.compact,Employee.pluck(column).uniq.compact.map{|x| Group.find_by(id: x).name}]]
      else
        employee_array << [column,Employee.pluck(column).uniq.compact]
      end
      employee_key << Employee.head_transfer[column]
    end
    gon.employee_key = employee_key
    gon.employee_array = employee_array
  end

  def wage_name_columns
    @wages = Wage.head_transfer.keys - ["col1","col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12"]
    wage_arry_string = []
    wage_arry = []

    @wages.each do |wage|
      wage_arry_string <<  Wage.head_transfer[wage]
      wage_arry << wage
    end
    gon.wage_arry = wage_arry_string
    gon.wages = wage_arry
  end

  def show_errors(exception)
    Rails.logger.error "遇到异常 #{exception.message}"
    Rails.logger.error exception.backtrace.try(:join, "\n")

    @exception = exception

    render file: 'apps/errors', status: 500
  end
end
