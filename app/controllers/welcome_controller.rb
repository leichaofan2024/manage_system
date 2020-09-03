class WelcomeController < ApplicationController

  def edit
  end

  def update_password
    user = User.find_by(name: params[:user_name])
    flash[:alert] = "未找到该账户！" and return redirect_to welcome_path unless user.present?
    user.update(password: params[:password], password_confirmation: params[:password])
    flash[:notice] = "更新成功！"
    redirect_to welcome_path
  end

end