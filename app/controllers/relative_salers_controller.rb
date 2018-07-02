class RelativeSalersController < ApplicationController
  layout 'home'
  def index
    @relative_salers = RelativeSaler.page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.csv { send_data @relative_salers.to_csv}
      format.xls
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      RelativeSaler.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to relative_salers_path
  end
end
