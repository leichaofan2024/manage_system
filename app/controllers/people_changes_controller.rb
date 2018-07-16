class PeopleChangesController < ApplicationController
  layout 'home'

  def index
    @changes = PeopleChange.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      PeopleChange.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to people_changes_path
    end
  end

  def new
    @change = PeopleChange.new
  end

  def create
    @change = PeopleChange.new
    if @change.save!
      flash[:notice] = "上传成功"
      redirect_to people_changes_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
