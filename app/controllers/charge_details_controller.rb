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

  def new
    @charge_detail = ChargeDetail.new
  end

  def create
    @charge_detail = ChargeDetail.new(charge_params)
    if @charge_detail.save!
      flash[:notice] = "上传成功"
      redirect_to charge_details_path
    else
      flash[:notice] = "上传失败"
    end
  end

  def upload

  end

  private
    def charge_params
      params.require(:charge_detail).permit(:upload_time)
    end

end
