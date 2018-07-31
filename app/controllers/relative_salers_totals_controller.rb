class RelativeSalersTotalsController < ApplicationController
  layout 'home'

  def index
    @totals = RelativeSalersTotal.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      RelativeSalersTotal.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to relative_salers_totals_path
  end

  def new
    @total = RelativeSalersTotal.new
  end

  def create
    @total = RelativeSalersTotal.new
    if @total.save!
      flash[:notice] = "上传成功"
      redirect_to relative_salers_totals_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
