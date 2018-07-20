# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, :only => [:cancel ]
  before_action :configure_sign_up_params, only: [:create]
  layout "home", only: [:new, :create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    hash = { "车间管理员" => 'workshopadmin', "科室管理员" => 'organsadmin', "班组管理员" => 'groupadmin', "领导" => 'leaderadmin' }
    @user = User.new(:name => params[:user][:name], :password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
    @user.add_role(hash[params[:user][:roles]])
    if @user.save
      flash[:notice] = "新增#{@user.name} 成功"
      redirect_to users_path
    else
      flash[:warning] = "新增失败"
      render :new
    end
  end

  # GET /resource/edit
  def edit
    render layout: 'home'
  end
  #
  #  PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
end
