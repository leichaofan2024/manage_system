class StarAwardsController < ApplicationController
  layout 'home'
  def index
    @star_awards = StarAward.page(params[:page]).per(15)
  end


  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      StarAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to star_awards_path
  end

  def new
    @star_award = StarAward.new
  end

  def create
    @star_award = StarAward.new
    if @star_award.save!
      flash[:notice] = "上传成功"
      redirect_to star_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end
end
