class BonusController < ApplicationController
	layout 'home'
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
