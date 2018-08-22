class Bonu < ApplicationRecord
	def self.import_table(file,year,month)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    # header = spreadsheet.row(1)
	    # header.each do |i|
	    # 	BonusHeader.create(:header => i)
	    # end

			bonus_import_message = Hash.new
	    bonus_headers = BonusHeader.pluck("header")
			form_headers = spreadsheet.row(1)
			n = 0
      form_headers.each do |fh|
        n += 1
        if !bonus_headers.include?(fh)
          bonus_import_message["head"] = "您上传的奖金表第#{n}列表头名‘#{fh}’与系统不匹配，请前往修改！"
        end
      end

			bonus_year_month_array = Bonu.pluck("year","month").uniq
			if bonus_year_month_array.include?([year.to_i,month.to_i])
				bonus_import_message["year_month"] = "#{year}年#{month}月奖金表已上传过，请勿重复上传！"
			end

			if !bonus_import_message["head"].present? && !bonus_import_message["year_month"].present?
				(1..(BonusHeader.count))
		    header_ids = (1..(BonusHeader.count)).map{|h| "col"+ h.to_s}
		    header_hash = Hash[[bonus_headers,header_ids].transpose]
		    header = form_headers.map{|i| header_hash[i]}
		    (2..spreadsheet.last_row).each do |j|
		        row = Hash[[header, spreadsheet.row(j)].transpose]
						bonu = Bonu.new
  	        if Employee.find_by(:sal_number => row[header_hash["工资号"]]).present?
  	        	employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).id
  	        	bonu.employee_id = employee_id
						end
            bonu.year = year.to_i
            bonu.month = month.to_i
		        bonu.attributes = row
		        bonu.save!

						wage_headers = WageHeader.pluck("header")
						wage_header_ids = (1..WageHeader.count).map{|m| "col"+ m.to_s}
		  	    wage_header_hash = [wage_headers,header_ids].transpose.to_h
            wage = Wage.find_by("#{wage_header_hash["工资号"]}" => row[header_hash["工资号"]],:year => year,:month => month)
            if wage.present?
							wage_jiangjin = (row[header_hash["挂钩工资"]]).t_i
                            + (row[header_hash["工费"]]).t_i
                            + (row[header_hash["安质工资"]]).t_i
                            + (row[header_hash["工质工资"]]).t_i
                            + (row[header_hash["行车考核"]]).t_i
                            + (row[header_hash["一体化奖"]]).t_i
                            + (row[header_hash["兼职兼岗"]]).t_i
                            + (row[header_hash["其他"]]).t_i
                            + (row[header_hash["管理"]]).t_i
                            + (row[header_hash["星级考核"]]).t_i
                            + (row[header_hash["标考奖"]]).t_i
                            + (row[header_hash["局先奖"]]).t_i
                            + (row[header_hash["一次性"]]).t_i
                            - (row[header_hash["考核扣款"]]).t_i

							row[header_hash["工资总额"]] = row[header_hash["应发工资"]]
	            #                            - row[header_hash["独补"]]
	            #                            - row[header_hash["托补"]]
	            #                            - row[header_hash["奶补"]]
	            #                            - row[header_hash["扣捆绑"]]
	            #                            - row[header_hash["扣捆挂"]]
	            #                            + row[header_hash["奖金"]]
							wage.update(wage_header_hash["奖金"] => wage_jiangjin)

						end
            # if bonus_month.blank?
            #   wage_import_message["bonus_blank"] = "要先上传奖金表哦！"
            #   redirect_to import_bonus_bonus_path
            # end
            # bonus_find_by = Bonu.find_by(:year => year,:month => month,:sal_number => row[header_hash["工资号"]])
            #
            # wage_not_in_bonus = []
            # if bonus_find_by.blank?
            #   row[header_hash["奖金"]] = 0
            #   wage_not_in_bonus << row[header_hash["工资号"]]
            # else
            #   bonus = bonus_find_by.attributes
            #   row[header_hash["奖金"]] = bonus[bonus_header_hash["挂钩工资"]]
            #                            + bonus[bonus_header_hash["工费"]]
            #                            + bonus[bonus_header_hash["安质工资"]]
            #                            + bonus[bonus_header_hash["工质工资"]]
            #                            + bonus[bonus_header_hash["行车考核"]]
            #                            + bonus[bonus_header_hash["一体化奖"]]
            #                            + bonus[bonus_header_hash["兼职兼岗"]]
            #                            + bonus[bonus_header_hash["其他"]]
            #                            + bonus[bonus_header_hash["管理"]]
            #                            + bonus[bonus_header_hash["星级考核"]]
            #                            + bonus[bonus_header_hash["标考奖"]]
            #                            + bonus[bonus_header_hash["局先奖"]]
            #                            + bonus[bonus_header_hash["一次性"]]
            #                            - bonus[bonus_header_hash["考核扣款"]]
            # end


            # row[header_hash["工资总额"]] = row[header_hash["应发工资"]]
            #                            - row[header_hash["独补"]]
            #                            - row[header_hash["托补"]]
            #                            - row[header_hash["奶补"]]
            #                            - row[header_hash["扣捆绑"]]
            #                            - row[header_hash["扣捆挂"]]
            #                            + row[header_hash["奖金"]]

            # row[header_hash["绩效工资"]] = row[header_hash["岗安考核"]]
            #                            + row[header_hash["加班费"]]
            #                            + row[header_hash["奖金"]]

		    end
      end
			return bonus_import_message
	end
end
