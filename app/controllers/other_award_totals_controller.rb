class OtherAwardTotalsController < ApplicationController
  layout 'home'
  def index
    @totals = OtherAwardTotal.page(params[:page]).per(15)
  end


  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      OtherAwardTotal.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to other_award_totals_path
  end

  def new
    @total= OtherAwardTotal.new
  end

  def create
    @total = OtherAwardTotal.new
    if @total.save!
      flash[:notice] = "上传成功"
      redirect_to other_award_totals_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end
end
