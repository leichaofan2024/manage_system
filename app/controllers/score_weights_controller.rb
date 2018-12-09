class ScoreWeightsController < ApplicationController
	layout 'home'

	def update_weight
		theory_score = params[:theory_score].to_i
		practical_score = params[:practical_score].to_i
		work_performance = params[:work_performance].to_i
		if theory_score + practical_score + work_performance != 100
			flash[:alert] = "您设置的3个权重总和不等于100%，请检查"
		else
			ScoreWeight.first.update(theory_score: (theory_score.to_f)/100, practical_score: (practical_score.to_f)/100, work_performance: (work_performance.to_f)/100)
			flash[:notice] = "更新成功"
		end
		redirect_to show_weight_score_weights_path
	end
end
