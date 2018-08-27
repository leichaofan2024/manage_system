class BonusController < ApplicationController
	layout 'home'

  def import_bonus
		if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month].to_i
		else
			bonu_year_month_array = Bonu.pluck(:year,:month).uniq.last
			if bonu_year_month_array.present?
				@year = bonu_year_month_array[0]
				@month = bonu_year_month_array[1]
			else
				@year = Time.now.year
				@month = Time.now.month
			end
		end
		@bonus = Bonu.where(:year => @year, :month => @month).page(params[:page]).per(20)
    #下载表格配置
    @export_bonus = Bonu.where(:year => @year, :month => @month)
    respond_to do |format|
      format.html
      format.xls
    end
  end

	# 删除工资表
  def delete_bonus
		@bonus = Bonu.where(:year => params[:year], :month => params[:month])
		@bonus.delete_all
		redirect_to import_bonus_bonus_path
		flash[:notice] = "已成功删除#{params[:year]}年#{params[:month]}月奖金表！"
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
			elsif import_message["wage_not_import"].present?
				flash[:alert] =import_message["wage_not_import"]
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
