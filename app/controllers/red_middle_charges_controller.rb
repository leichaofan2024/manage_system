class RedMiddleChargesController < ApplicationController
  layout 'home'

  def index
    @charges = RedMiddleCharge.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      RedMiddleCharge.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to red_middle_charges_path
  end

end
