class WagesController < ApplicationController
	layout 'home'
	def import_wage
		@wages = Wage.page(params[:page]).per(20)
    #下载表格配置
    @export_wages = Wage.all
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
      import_message = Wage.import_table(params[:file],params[:year],params[:month])
      if import_message["head"].present?
        flash[:alert] = import_message["head"]
			end
    end
    redirect_to import_wage_wages_path
  end

  def create_header
    if WageHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      WageHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_wage_wages_path
  end

  def edit_header
    wage_header = WageHeader.find_by(header: params[:before_header])
    wage_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_wage_wages_path
  end

end
