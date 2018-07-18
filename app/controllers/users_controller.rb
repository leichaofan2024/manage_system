class UsersController < ApplicationController
  layout 'home'

  def index
    @users = User.page(params[:page]).per(10)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

  end

  def edit

  end

  def update

  end

  def destroy

  end

  private
    

end
