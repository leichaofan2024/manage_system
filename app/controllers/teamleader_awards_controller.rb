class TeamleaderAwardsController < ApplicationController
  layout 'home'

  def index
    @teamleader_awards = TeamleaderAward.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      TeamleaderAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to teamleader_awards_path
  end

  def new
    @teamleader_award = TeamleaderAward.new
  end

  def create
    @teamleader_award = TeamleaderAward.new
    if @teamleader_award.save!
      flash[:notice] = "上传成功"
      redirect_to teamleader_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end


end
