class StarInfosController < ApplicationController
	layout 'home'

	def all_star_info
		@scores = BasicScore.all
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
			render "star_infos/all_star_info"
		else
			star.update(star: updated_star)
			flash[:notice] = "更新完成"
			redirect_to all_star_info_star_infos_path
		end	
	end
end
end
