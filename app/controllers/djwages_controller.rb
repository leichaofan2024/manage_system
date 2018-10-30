class DjwagesController < ApplicationController
  layout 'home'
  def index
	end


	def import_djwage
		if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month].to_i
		else
			djwage_year_month_array = Djwage.pluck(:year,:month).uniq.last
			if djwage_year_month_array.present?
				@year = djwage_year_month_array[0]
				@month = djwage_year_month_array[1]
			else
				@year = Time.now.year
				@month = Time.now.month
			end
		end
		@djwages = Djwage.where(:year => @year, :month => @month).page(params[:page]).per(20)
    #下载表格配置
    @export_djwages = Djwage.where(:year => @year, :month => @month)
    respond_to do |format|
      format.html
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工资表.xls"'}
    end
	end


  # 删除工资表
  def delete_djwage
		@djwages = Djwage.where(:year => params[:year], :month => params[:month])
		@djwages.delete_all
		redirect_to import_djwage_djwages_path
		flash[:notice] = "已成功删除#{params[:year]}年#{params[:month]}月工资表！"
	end

	#工资表表头公式表单
	def edit_header_formula
		@year = params[:year]
		@month = params[:month]
		@header_name = params[:header_name]
		@formula = DjwageHeader.find_by(:header => @header_name).formula
		@djwage_headers = DjwageHeader.pluck(:header)
		@bonus_headers = BonusHeader.pluck(:header)

	end

#生成工资表头公式及更新带公式的列数据
	def update_header_formula
		@year = params[:year]
		@month = params[:month]
		@header_name = params[:header_name]
    @params_hash = params.delete_if{|key,value| ["year","month","header_name","utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
		@djwages = Djwage.where(:year => @year,:month => @month)
		djwage_headers = DjwageHeader.pluck("header")
    header_ids = (1..DjwageHeader.count).map{|m| "col"+ m.to_s}
    header_hash = [djwage_headers,header_ids].transpose.to_h

		if @params_hash.present?
      DjwageHeader.find_by(:header => @header_name).update(:formula => @params_hash)
			@djwages.each do |djwage|
				djwage_attributes = djwage.attributes
				djwage_value = 0.0
				@params_hash.keys.each do |key|
					if @params_hash[key].to_i == 1
						djwage_value = (djwage_value + djwage_attributes[key].to_f)
					elsif @params_hash[key].to_i == 2
						djwage_value = (djwage_value - djwage_attributes[key].to_f)
					end
				end
				djwage.update(header_hash[@header_name] => djwage_value)
			end
			flash[:notice] = "#{@header_name}公式及数据更新成功！"
			redirect_to import_djwage_djwages_path(:year => @year ,:month => @month)
		else
			redirect_to import_djwage_djwages_path(:year => @year ,:month => @month)
		end

	end

	#上传表格
  def import_table
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      import_message = Djwage.import_table(params[:file],params[:year],params[:month])
      if import_message["head"].present?
        flash[:alert] = import_message["head"]
			elsif import_message["year_month"].present?
				flash[:alert] = import_message["year_month"]
			else
				flash[:notice] = "上传成功"
			end
    end
    redirect_to import_djwage_djwages_path
  end

  def create_header
    if DjwageHeader.find_by(header: params[:header]).present?
      flash[:alert] = "您填写的表头已存在"
    else
      DjwageHeader.create(header: params[:header])
      flash[:notice] = "新增成功"
    end
    redirect_to import_djwage_djwages_path
  end

  def edit_header
    djwage_header = DjwageHeader.find_by(header: params[:before_header])
    djwage_header.update(header: params[:after_header])
    flash[:notice] = "修改成功"
    redirect_to import_djwage_djwages_path
  end

end
