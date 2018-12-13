class StarApplicationsController < ApplicationController
	layout 'home'

	def index
		if params[:type] == "1"
			@applications = StarApplication.where(status: 1)
		else
			@applications = StarApplication.where(status: 0)
		end
	end

	def refuse_application
		application = StarApplication.find(params[:application])
		basic_score = BasicScore.find(StarInfo.find(application.star_info_id).basic_score_id)
		if basic_score.confirm_status == 1
			StarApplication.find(params[:application]).update(status: 1, treatment_state: "拒绝")
			flash[:notice] = "已拒绝本次申请，流程结束"
		else
			flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
		end
		redirect_to star_applications_path(type: 0)
	end

	def agree_application
		application = StarApplication.find(params[:application])
		updated_star = (StarInfo.find(application.star_info_id).star).to_i + application.up_down_star	
		basic_score = BasicScore.find(StarInfo.find(application.star_info_id).basic_score_id)
		if basic_score.confirm_status == 1
			if (updated_star > 5) || (updated_star < 1)
				flash[:alert] = "升/降星后该人员的星级高于五星或低于一星，请检查"
			else
				application.update(status: 1, treatment_state: "通过")
				StarInfo.find(application.star_info_id).update(star: updated_star)
				flash[:notice] = "您已通过本次申请，系统已自动更新该人员的星级"
			end
		else
			flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
		end
		redirect_to star_applications_path(type: 0)
	end

	def create_application
		up_down_star = (params[:update_type] + params[:star_count]).to_i
		 
		if StarInfo.find_by(name: params[:name], sal_number: params[:sal_number], year: params[:year], quarter: params[:quarter]).present?
			star_info = StarInfo.find_by(name: params[:name], sal_number: params[:sal_number], year: params[:year], quarter: params[:quarter])
			if (((star_info.star).to_i + up_down_star).to_i > 0) && (((star_info.star).to_i + up_down_star).to_i < 6)
				StarApplication.create(star_info_id: star_info.id, up_down_star: up_down_star, applicant: current_user.name)
				flash[:notice] = "成功发起申请"
			else
				
				flash[:alert] = "通过申请后该人员的星级将低于一星或高于五星，请检查"
			end
		else
			flash[:alert] = "您填写的工资号或姓名不在系统内，请先上传"
		end
		redirect_to new_star_application_path
	end
end
