class ExaminationChargesController < ApplicationController
 layout 'home'

  def index
    @examination_charges = ExaminationCharge.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      ExaminationCharge.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
    end
    redirect_to examination_charges_path
  end

  def new
    @examination_charge = ExaminationCharge.new
  end

  def create
    @examination_charge = ExaminationCharge.new
    if @examination_charge.save!
      flash[:notice] = "上传成功"
      redirect_to examination_charges_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end

end
