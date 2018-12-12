class StarInfosController < ApplicationController
	layout 'home'

	def all_star_info
		@year = params[:year]
		@quarter = params[:quarter]
		@type = params[:type]
		quarter_month = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
		quarter_month.each do |i|
			if i.include?(Time.now.month)
				@current_quarter = (quarter_month.index(i) + 1)
			end
		end
		if (@year.present?) || (@quarter.present?)
			if @type == "passed"
				@scores = BasicScore.where(confirm_status: 1, year: @year, quarter: @quarter)
			else
				@scores = BasicScore.where(year: @year, quarter: @quarter)
			end
		else
			if @type == "passed"
				@scores = BasicScore.where(confirm_status: 1, year: Time.now.year, quarter: @current_quarter)
			else
				@scores = BasicScore.where(year: Time.now.year, quarter: @current_quarter)
			end
		end
		@export_scores = @scores
		respond_to do |format|
	      format.html
	      format.js
	      format.xls { headers["Content-Disposition"] = 'attachment; filename="全部星级岗位表.xls"'}
	    end
	end

	def show_star_modal
	@star_info = params[:star_info]
	respond_to do |format|
		format.js
	end

	def update_star
		@scores = BasicScore.all
		star = StarInfo.find(params[:star_info])
		updated_star = (star.star).to_i + (params[:update_type] + params[:star_count]).to_i
		if (updated_star > 5) || (updated_star < 1)
			flash[:alert] = "升/降星后该人员的星级高于五星或低于一星，请检查"
		else
			star.update(star: updated_star)
			flash[:notice] = "更新完成"	
		end	
		redirect_to all_star_info_star_infos_path
	end
end
end
