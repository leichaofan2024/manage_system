class BasicScore < ApplicationRecord
	def self.import_table(file,workshop,year,quarter)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      import_form_head = spreadsheet.row(1)
      basic_form_head = BasicScore.columns 
      message = Hash.new
      import_form_head.each do |import_head| 
      	if !basic_form_head.include?(import_head)
          message[:head] = "表头《#{import_head}》与系统不匹配，请更正后再上传！"
      	end 
      end 
      year_quarter_already = BasicScore.find_by(:workshop => workshop,:year => year,:quarter => quarter)
      if year_quarter_already.present?
        message[:year_quarter] = "#{workshop}#{year}年第#{quarter}季度考勤汇总表已存在，请勿重复上传！" 
      end 
      if message.blank?
      	score_weight = ScoreWeight.first
        (2..spreadsheet.last_row).each do |n|
        	row = [spreadsheet.row(1),spreadsheet.row(n)].transpose.to_h
          row["workshop"] = workshop
          row["year"] = year.to_i
          row["quarter"] = quarter.to_i
          row["theory_weighted_score"] = row["theory_score"].to_f * score_weight.theory_score
          row["practical_weighted_score"] = row["practical_score"].to_f * score_weight.practical_score
          row["work_performance_weighted_score"] = row["work_performance"].to_f * score_weight.work_performance
          row["final_score"] = row["theory_weighted_score"] + row["practical_weighted_score"] + row["work_performance_weighted_score"] + row["extra_score"].to_f
          basic_score = BasicScore.create(row)
          star_info_row = Hash.new 
          star_info_row["basic_score_id"] = basic_score.id 
          star_info_row["year"] = year.to_i
          star_info_row["quarter"] = quarter.to_i
          star_info_row["workshop"] = workshop
          star_info_row["group"] = row["group"]
          star_info_row["name"] = row["name"]
          star_info_row["sal_number"] = row["sal_number"]
          star_info_row["duty"] = row["duty"]
          star_info_row["final_score"] = row["final_score"]
          StarInfo.create(star_info_row)
        end 
        star_infos = StarInfo.where(:workshop => workshop,:year => year ,:quarter => quarter).order("final_score DESC")
        all_count = star_infos.count 
        five_star_count = (all_count * (StarRange.find_by(:name => 5).value)).to_i
        four_star_count = (all_count * (StarRange.find_by(:name => 4).value)).to_i
        three_star_count = (all_count * (StarRange.find_by(:name => 3).value)).to_i
        two_star_count = (all_count * (StarRange.find_by(:name => 2).value)).to_i
        star_infos.first(five_star_count).update(:star => "pre_5")
        star_infos.offset(five_star_count).first(four_star_count).update(:star => 4)
        star_infos.offset(five_star_count+four_star_count).first(three_star_count).update(:star => 3)
        star_infos.offset(five_star_count+four_star_count+three_star_count).first(two_star_count).update(:star => 2)
        star_infos.offset(five_star_count+four_star_count+three_star_count+two_star_count).update(:star => 1)
      end 
	end 
end
