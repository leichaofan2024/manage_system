class StandardGroupsController < ApplicationController
  layout 'home'

  def index
    @standard_groups = StandardGroup.page(params[:page]).per(15)
  end


  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      StandardGroup.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to standard_groups_path
  end

  def new
    @standard_group = StandardGroup.new
  end

  def create
    @standard_group = StandardGroup.new
    if @standard_group.save!
      flash[:notice] = "上传成功"
      redirect_to standard_groups_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
