class ScoreWeightsController < ApplicationController
	layout 'home'

	def update_weight
		theory_score = params[:theory_score].to_i
		practical_score = params[:practical_score].to_i
		work_performance = params[:work_performance].to_i
		if theory_score + practical_score + work_performance != 100
			flash[:alert] = "您设置的3个权重总和不等于100%，请检查"
			render "score_weights/show_weight"
		else
			if ScoreWeight.first.present? 
			  ScoreWeight.first.update(theory_score: (theory_score.to_f)/100, practical_score: (practical_score.to_f)/100, work_performance: (work_performance.to_f)/100)
			else 
				ScoreWeight.create(theory_score: (theory_score.to_f)/100, practical_score: (practical_score.to_f)/100, work_performance: (work_performance.to_f)/100)
			end 
			flash[:notice] = "更新成功"
			redirect_to show_weight_score_weights_path
		end
		
	end
end
