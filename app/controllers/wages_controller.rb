class WagesController < ApplicationController
	layout 'home'
	def import_wage
		
	end

	#上传表格
  def import_table
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      Wage.import_table(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to import_wage_wages_path
  end
end
