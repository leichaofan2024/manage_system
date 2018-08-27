class Bonu < ApplicationRecord
	def self.head_transfer
    bonus_headers = BonusHeader.pluck("header")
    header_ids = (1..BonusHeader.count).map{|m| "col"+ m.to_s}
    header_hash = [bonus_headers,header_ids].transpose.to_h
		return header_hash
	end

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

			# 同月是否上传对应工资表：
			wage_duiying = Wage.find_by(:year => year, :month => month)
			if wage_duiying.blank?
				bonus_import_message["wage_not_import"] ="请先上传#{year}年#{month}月工资表！"
			end

			bonus_year_month_array = Bonu.pluck("year","month").uniq
			if bonus_year_month_array.include?([year.to_i,month.to_i])
				bonus_import_message["year_month"] = "#{year}年#{month}月奖金表已上传过，请勿重复上传！"
			end

			if !bonus_import_message["head"].present? && !bonus_import_message["year_month"].present? && bonus_import_message["wage_not_import"].blank?
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
		  	    wage_header_hash = [wage_headers,wage_header_ids].transpose.to_h
            wage = Wage.find_by("#{wage_header_hash["工资号"]}" => row[header_hash["工资号"]],:year => year,:month => month)
            if wage.present?
							wage_attributes = wage.attributes
							# 工资表奖金：
							wage_jiangjin = (row[header_hash["挂钩工资"]]).to_i
                            + (row[header_hash["工费"]]).to_i
                            + (row[header_hash["安质工资"]]).to_i
                            + (row[header_hash["工质工资"]]).to_i
                            + (row[header_hash["行车考核"]]).to_i
                            + (row[header_hash["一体化奖"]]).to_i
                            + (row[header_hash["兼职兼岗"]]).to_i
                            + (row[header_hash["其他"]]).to_i
                            + (row[header_hash["管理"]]).to_i
                            + (row[header_hash["星级考核"]]).to_i
                            + (row[header_hash["标考奖"]]).to_i
                            + (row[header_hash["局先奖"]]).to_i
                            + (row[header_hash["一次性"]]).to_i
                            - (row[header_hash["考核扣款"]]).to_i
           # 工资表工资总额
           wage_gongzizonge = (wage_attributes[wage_header_hash["应发工资"]]).to_i
                            - (wage_attributes[wage_header_hash["独补"]]).to_i
                            - (wage_attributes[wage_header_hash["托补"]]).to_i
                            - (wage_attributes[wage_header_hash["奶补"]]).to_i
                            - (wage_attributes[wage_header_hash["扣捆绑"]]).to_i
                            - (wage_attributes[wage_header_hash["扣捆挂"]]).to_i
                            + wage_jiangjin
           # 工资表绩效工资
           wage_jixiaogongzi = wage_attributes[wage_header_hash["岗安考核"]]
                             + wage_attributes[wage_header_hash["加班费"]]
                             + wage_jiangjin

					wage.update(wage_header_hash["奖金"] => wage_jiangjin,wage_header_hash["工资总额"] => wage_gongzizonge,wage_header_hash["绩效工资"] => wage_jixiaogongzi )
						end

		    end
      end
			return bonus_import_message
	end
end
