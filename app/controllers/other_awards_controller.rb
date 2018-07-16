class OtherAwardsController < ApplicationController
  layout 'home'

  def index
    @other_awards = OtherAward.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      OtherAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to other_awards_path
    end
  end

  def new
    @other_award = OtherAward.new
  end

  def create
    @other_award = OtherAward.new
    if @other_award.save!
      flash[:notice] = "上传成功"
      redirect_to other_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
