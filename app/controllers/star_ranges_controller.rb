class StarRangesController < ApplicationController
	layout 'home'

	def update_range
		f_type = [params[:f_type1], params[:f_type2], params[:f_type3], params[:f_type4], params[:f_type5]]
		if (f_type.uniq.count > 1) && ((params[:value1].to_i + params[:value2].to_i + params[:value3].to_i + params[:value4].to_i + params[:value5].to_i) == 100)
			(1..5).each do |i|
				f_type = "f_type" + i.to_s
				value = "value" + i.to_s
				money = "money" + i.to_s
				star_range = StarRange.find_by(name: i)
				if star_range.present? 
					star_range.update(f_type: params[:"#{f_type}"], value: (params[:"#{value}"].to_f)/100, money: params[:"#{money}"])
				else
					star_range = StarRange.create(:name => i)
					star_range.update(f_type: params[:"#{f_type}"], value: (params[:"#{value}"].to_f)/100, money: params[:"#{money}"])
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
