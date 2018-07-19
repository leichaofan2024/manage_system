class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_user

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

end
