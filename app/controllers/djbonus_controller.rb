class DjbonusController < ApplicationController
  layout 'home'

  def import_djbonus
		if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month].to_i
		else
			djbonu_year_month_array = Djbonu.pluck(:year,:month).uniq.last
			if djbonu_year_month_array.present?
				@year = djbonu_year_month_array[0]
				@month = djbonu_year_month_array[1]
			else
				@year = Time.now.year
				@month = Time.now.month
			end
		end
		@djbonus = Djbonu.where(:year => @year, :month => @month).page(params[:page]).per(20)
    #下载表格配置
    @export_djbonus = Djbonu.where(:year => @year, :month => @month)
    respond_to do |format|
      format.html
      format.xls { headers["Content-Disposition"] = 'attachment; filename="表格配置下载.xls"'}
    end
  end

	# 删除工资表
  def delete_djbonus
		@djbonus = Djbonu.where(:year => params[:year], :month => params[:month])
		@djbonus.delete_all
		redirect_to import_djbonus_djbonus_path
		flash[:notice] = "已成功删除#{params[:year]}年#{params[:month]}月奖金表！"
	end

	#上传表格
  def import_table
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      import_message = Djbonu.import_table(params[:file],params[:year],params[:month])
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
    redirect_to import_djbonus_djbonus_path
  end

  def create_header
    if DjbonusHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      DjbonusHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_djbonus_djbonus_path
  end

  def edit_header
    djbonus_header = DjbonusHeader.find_by(header: params[:before_header])
    djbonus_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_djbonus_djbonus_path
  end

	def edit_header_formula
		@year = params[:year]
		@month = params[:month]
		@header_name = params[:header_name]
		@formula = DjbonusHeader.find_by(:header => @header_name).formula
		@djbonus_headers = DjbonusHeader.pluck(:header)
	end

  def update_header_formula
		@year = params[:year]
		@month = params[:month]
		@header_name = params[:header_name]
    @params_hash = params.delete_if{|key,value| ["year","month","header_name","utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
		@djbonus = Djbonu.where(:year => @year,:month => @month)

		djbonus_headers = DjbonusHeader.pluck("header")
		djbonu_header_ids = (1..(DjbonusHeader.count)).map{|h| "col"+ h.to_s}
		header_hash = [djbonus_headers,djbonu_header_ids].transpose.to_h

		if @params_hash.present?
      DjbonusHeader.find_by(:header => @header_name).update(:formula => @params_hash)
			@djbonus.each do |djbonus|
				djbonus_attributes = djbonus.attributes
				djbonus_value = 0
				@params_hash.keys.each do |key|
					if @params_hash[key].to_i == 1
						djbonus_value = (djbonus_value + djbonus_attributes[key].to_f)
					elsif @params_hash[key].to_i == 2
						djbonus_value = (djbonus_value - djbonus_attributes[key].to_f)
					end
				end
				djbonus.update(header_hash[@header_name] => djbonus_value)
			end
			flash[:notice] = "#{@header_name}公式及数据更新成功！"
			redirect_to import_djbonus_djbonus_path(:year => @year ,:month => @month)
		else
			redirect_to import_djbonus_djbonus_path(:year => @year ,:month => @month)
		end
	end
end
