class AnnualHolidayPlan < ApplicationRecord
	def self.head_transfer 
		head_transfer_hash = Hash.new 

		head_transfer_hash = {
                              "工种" => "work_type",
                              "上年末部门人数" => "last_year_people_number",
			        		  "符合条件休年休假人数" => "this_year_people_number",
			        		  "休5天人数" => "five_days",
			        		  "休10天人数" => "ten_days",
			        		  "休15天人数" => "fifteen_days",
			        		  "应休假天数" => "holiday_days",
			        		  "1月份安排人数" => "January_plan_number",
			        		  "1月份休假天数" => "January_plan_days",
			        		  "2月份安排人数" => "February_plan_number",
			        		  "2月份休假天数" => "February_plan_days",
			        		  "3月份安排人数" => "March_plan_number",
			        		  "3月份休假天数" => "March_plan_days",
			        		  "4月份安排人数" => "April_plan_number",
			        		  "4月份休假天数" => "April_plan_days",
			        		  "5月份安排人数" => "May_plan_number",
			        		  "5月份休假天数" => "May_plan_days",
			        		  "6月份安排人数" => "June_plan_number",
			        		  "6月份休假天数" => "June_plan_days",
			        		  "7月份安排人数" => "July_plan_number",
			        		  "7月份休假天数" => "July_plan_days",
			        		  "8月份安排人数" => "August_plan_number",
			        		  "8月份休假天数" => "August_plan_days",
			        		  "9月份安排人数" => "September_plan_number",
			        		  "9月份休假天数" => "September_plan_days",
			        		  "10月份安排人数" => "October_plan_number",
			        		  "10月份休假天数" => "October_plan_days",
			        		  "11月份安排人数" => "November_plan_number",
			        		  "11月份休假天数" => "November_plan_days",
			        		  "12月份安排人数" => "December_plan_number",
			        		  "12月份休假天数" => "December_plan_days"
                         
                              }
        return head_transfer_hash
	end 
	def self.import_table(year,file,workshop,workshop_id)
		message = Hash.new
		spreadsheet = Roo::Spreadsheet.open(file.path)
		import_form_heads = spreadsheet.row(1)

		# 对比上传的表头是否准确：
		message[:wrong_heads] = []
        import_form_heads.each do |head|
          if  !AnnualHolidayPlan.head_transfer.keys.include?(head)
          	message[:wrong_heads] << head 
          end 
        end 

        # 检查本年度是否已上传：
        if workshop =="workshop"
        	annual_holiday_plans = AnnualHolidayPlan.where(:year => year,:workshop_id => workshop_id)
        elsif workshop == "group"
        	annual_holiday_plans = AnnualHolidayPlan.where(:year => year,:orgnization_id => workshop_id)
        end 
        if annual_holiday_plans.present? 
        	message[:already_import] = "#{year}年年休假计划已存在，请勿重复上传！"
        end 
        
        work_type_array = AnnualHolidayWorkType.pluck(:work_type)
        if message[:wrong_heads].blank? && message[:already_import].blank?
	        import_form_head_transfers = spreadsheet.row(1).map{|x| AnnualHolidayPlan.head_transfer[x]}
	        (2..spreadsheet.last_row).each do |n| 
	            row = [import_form_head_transfers,spreadsheet.row(n)].transpose.to_h
	            row["year"] = year 
	            if workshop =="workshop"
	              row["workshop_id"] = workshop_id.to_i
	            elsif workshop == "group"
	              row["orgnization_id"] = workshop_id.to_i
	            end 
	            work_type = row["work_type"]
                if !work_type_array.include?(work_type)
                	message[:work_type_wrong] = "工种《#{work_type}》与系统不匹配，请核对后再上传！"
                else 
                	row["work_type"] = AnnualHolidayWorkType.find_by(:work_type => work_type).id
                end 
                AnnualHolidayPlan.create!(row)
		     end 
             if message[:work_type_wrong].present?
                 annual_holiday_plans.delete_all
             end 
		end 
		return message
	end 
end
