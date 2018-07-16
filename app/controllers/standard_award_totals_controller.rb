class StandardAwardTotalsController < ApplicationController
  layout 'home'

  def index
    @totals = StandardAwardTotal.page(params[:page]).per(15)
  end


  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      StandardAwardTotal.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to standard_award_totals_path
  end

  def new
    @total = StandardAwardTotal.new
  end

  def create
    @total = StandardAwardTotal.new
    if @total.save!
      flash[:notice] = "上传成功"
      redirect_to standard_award_totals_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
