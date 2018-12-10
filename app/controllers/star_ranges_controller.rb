class StarRangesController < ApplicationController
	layout 'home'

	def update_range
		range_type = [params[:range_type1], params[:range_type2], params[:range_type3], params[:range_type4], params[:range_type5]]
		if (range_type.uniq.count > 1) && ((params[:value1].to_i + params[:value2].to_i + params[:value3].to_i + params[:value4].to_i + params[:value5].to_i) == 100)
			(1..5).each do |i|
				range_type = "range_type" + i.to_s
				value = "value" + i.to_s
				money = "money" + i.to_s
				if params[:"#{money}"].present?
					StarRange.find_by(name: i).update(range_type: params[:"#{range_type}"], value: (params[:"#{value}"].to_f)/100, money: params[:"#{money}"])
				else
					StarRange.find_by(name: i).update(range_type: params[:"#{range_type}"], value: (params[:"#{value}"].to_f)/100)
				end
			end
			flash[:notice] = "更新成功"
			redirect_to show_range_star_ranges_path
		else
			flash[:alert] = "您填写的比例总和不等于100%，或都为“大于等于”或“小于等于”，请检查"
			render "star_ranges/show_range"
		end
	end
end
