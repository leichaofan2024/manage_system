class UsersController < ApplicationController
  layout 'home'
  before_action :required_is_admin

  def index
    @users = User.where.not(id: current_user.id).page(params[:page]).per(10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "新增#{@user.name} 成功"
      redirect_to users_path
    else
      flash[:warning] = "新增失败"
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(new_params)
      flash[:notice] = "#{@user.name} 的信息更新成功"
      redirect_to user_path(params[:id])
    else
      flash[:warngin] = "更新信息失败"
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "#{@user.name} 已删除"
    redirect_to users_path
  end

  private

    def user_params
      params.require(:users).permit(:name, :password, :password_confirmation)
    end

end
