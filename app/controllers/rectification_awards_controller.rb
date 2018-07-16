class RectificationAwardsController < ApplicationController
  layout 'home'


  def index
    @rectifications = RectificationAward.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      RectificationAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to rectification_awards_path
    end
  end

  def new
    @rectifications = RectificationAward.new
  end

  def create
    @rectifications = RectificationAward.new
    if @rectifications.save!
      flash[:notice] = "上传成功"
      redirect_to rectification_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end


end
