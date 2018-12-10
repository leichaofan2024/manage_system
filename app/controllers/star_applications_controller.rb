class StarApplicationsController < ApplicationController
	layout 'home'

	def index
		if params[:type] == "0"
			@applications = StarApplication.where(status: 0)
		elsif params[:type] == "1"
			@applications = StarApplication.where(status: 1)
		end
	end

	def refuse_application
		StarApplication.find(params[:application]).update(status: 1, treatment_state: "拒绝")
		flash[:notice] = "已拒绝本次申请，流程结束"
		redirect_to star_applications_path
	end

	def agree_application
		application = StarApplication.find(params[:application])
		updated_star = (StarInfo.find(application.star_info_id).star).to_i + application.up_down_star	
		if (updated_star > 5) || (updated_star < 1)
			flash[:alert] = "升/降星后该人员的星级高于五星或低于一星，请检查"
		else
			application.update(status: 1, treatment_state: "通过")
			StarInfo.find(application.star_info_id).update(star: updated_star)
			flash[:notice] = "您已通过本次申请，系统已自动更新该人员的星级"
		end
		redirect_to star_applications_path
	end

	def create_application
		
	end
end
