class RedMiddleChargesController < ApplicationController
  layout 'home'

  def index
    @charges = RedMiddleCharge.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      RedMiddleCharge.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to red_middle_charges_path
    end
  end

  def new
    @charge = RedMiddleCharge.new
  end

  def create
    @charge = RedMiddleCharge.new
    if @charge.save!
      flash[:notice] = "上传成功"
      redirect_to red_middle_charges_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
