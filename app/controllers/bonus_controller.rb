class BonusController < ApplicationController
	layout 'home'

  def import_bonus
		if params[:year].present? && params[:month].present? 
		else
    	@bonus = Bonu.page(params[:page]).per(20)
		end
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
        import_message = Bonu.import_table(params[:file],params[:year],params[:month])
				if import_message["head"].present?
	        flash[:alert] = import_message["head"]
				elsif import_message["year_month"].present?
					flash[:alert] = import_message["year_month"]
				else
        	flash[:notice] = "上传成功"
				end
      end
      redirect_to import_bonus_bonus_path
    end

    def create_header
    if BonusHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      BonusHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_bonus_bonus_path
  end

  def edit_header
    bonus_header = BonusHeader.find_by(header: params[:before_header])
    bonus_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_bonus_bonus_path
  end

end
