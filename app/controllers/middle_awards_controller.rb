class MiddleAwardsController < ApplicationController
  layout 'home'

  def index
    @middle_awards = MiddleAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      MiddleAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to middle_awards_path
    end
  end

  def new
    @middle_award = MiddleAward.new
  end

  def create
    @middle_award = MiddleAward.new
    if @middle_award.save!
      flash[:notice] = "上传成功"
      redirect_to middle_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
