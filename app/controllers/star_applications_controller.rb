class StarApplicationsController < ApplicationController
	layout 'home'

	def index
		@type = params[:type]
		if @type == "1"
			@applications = StarApplication.where(status: 1)
		else
			@applications = StarApplication.where(status: 0)
		end
	end 

	def refuse_application
		application = StarApplication.find(params[:application])
		basic_score = BasicScore.find(StarInfo.find(application.star_info_id).basic_score_id)
		star_confirm_status = StarConfirmStatus.find_by(:year => basic_score.year,:quarter => basic_score.quarter)
		if star_confirm_status.present?
			if star_confirm_status.status == true
				StarApplication.find(params[:application]).update(status: 1, treatment_state: "拒绝")
				flash[:notice] = "已拒绝本次申请，流程结束"
			else
				flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
			end
		else
			flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
		end
		redirect_to star_applications_path(type: 0)
	end

	def agree_application
		application = StarApplication.find(params[:application])
		star_info = StarInfo.find(application.star_info_id)
		updated_star = (star_info.star).to_i + application.up_down_star	
		basic_score = BasicScore.find(StarInfo.find(application.star_info_id).basic_score_id)
		star_confirm_status = StarConfirmStatus.find_by(:year => basic_score.year,:quarter => basic_score.quarter)
		if star_confirm_status.present?
			if star_confirm_status.status == true
				if (updated_star > 5) || (updated_star < 1)
					flash[:alert] = "升/降星后该人员的星级高于五星或低于一星，请检查"
				else
					if application.up_down_star < 0
						DescendRecord.create(year: star_info.year, quarter: star_info.quarter, sal_number: star_info.sal_number, application_id: application.id, descend_type: "降星")
					else
						StarInfo.find(application.star_info_id).update(star: updated_star)
					end
					application.update(status: 1, treatment_state: "通过")
					flash[:notice] = "您已通过本次申请，系统已自动更新该人员的星级"
				end
			else
				flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
			end
		else
			flash[:alert] = "您还未完成本季度的评定，请完成后再处理申请"
		end
		redirect_to star_applications_path(type: 0)
	end

	def create_application
		up_down_star = (params[:update_type] + params[:star_count]).to_i
		if StarConfirmStatus.find_by(year: params[:year], quarter: params[:quarter]).present?
			if StarConfirmStatus.find_by(year: params[:year], quarter: params[:quarter]).status == true
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
			else
				flash[:alert] = "当前季度的星级评定还未完成，请于完成后再申请升降星"
			end
		else
			flash[:alert] = "当前季度的星级评定还未完成，请于完成后再申请升降星"
		end
		redirect_to new_star_application_path
	end
end
