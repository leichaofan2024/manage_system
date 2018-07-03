class BonusController < ApplicationController
	layout 'home'

  def import_bonus
    @bonus = Bonu.page(params[:page]).per(20)
    #下载表格配置
    @export_bonus = Bonu.all
    respond_to do |format|
      format.html
      format.xls
    end
  end

	#上传表格
    def import_table
      if !params[:file].present?
        flash[:alert] = "您还没有选择文件哦"
      else
        Bonu.import_table(params[:file])
        flash[:notice] = "上传成功"
      end
      redirect_to import_bonus_bonus_path
    end
end
