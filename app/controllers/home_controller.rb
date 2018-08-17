class HomeController < ApplicationController
  layout 'home'
  def index
    if (current_user.has_role? :groupadmin) || (current_user.has_role? :organsadmin) || (current_user.has_role? :wgadmin)
      redirect_to group_attendances_path
    elsif (current_user.has_role? :workshopadmin) || (current_user.has_role? :attendance_admin)
      redirect_to group_current_time_info_attendances_path
    else
      redirect_to employees_path
    end
  end
end
