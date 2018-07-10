class ExaminationChargesController < ApplicationController
 layout 'home'
 
  def index
    @examination_charges = ExaminationCharge.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      ExaminationCharge.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to examination_charges_path
  end

end
