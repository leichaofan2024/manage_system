class ChargeDetailsController < ApplicationController
  layout 'home'

  def index
    @charge_details = ChargeDetail.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.csv { send_data @charge_details.to_csv}
      format.xls
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      ChargeDetail.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to charge_details_path
  end

  def upload

  end


end
