class HomeController < ApplicationController
  layout 'home'
  def index
    if (current_user.has_role? :groupadmin) || (current_user.has_role? :organsadmin) || (current_user.has_role? :wgadmin)
      redirect_to group_attendances_path
    elsif (current_user.has_role? :attendance_admin)
      redirect_to group_current_time_info_attendances_path(:group => 593)
    elsif (current_user.has_role? :workshopadmin)
      groups = Group.where(:workshop_id => current_user.workshop_id)
      redirect_to group_current_time_info_attendances_path(:group => groups.first.id)
    else
      redirect_to employees_path
    end
  end
end
