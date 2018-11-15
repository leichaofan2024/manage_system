class Wage < ApplicationRecord

scope :total_wage, -> { where.not(:id => LeavingEmployee.where(:leaving_type => "调离").pluck("employee_id"))}
  def self.head_transfer
    wage_headers = WageHeader.pluck("header")
    header_ids = (1..WageHeader.count).map{|m| "col"+ m.to_s}
    header_hash = [header_ids,wage_headers].transpose.to_h
		return header_hash
	end


	def self.import_table(file,year,month)
      wage_import_message = Hash.new
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    header_name = spreadsheet.row(1)
      # header_name += ["奖金二","工资总额","基本工资","绩效工资","津贴补贴","岗位工资","技能工资","加班工资","主业工资"]
	    # header_name.each do |i|
	    # 	WageHeader.create(:header => i)
	    # end

	  	wage_headers = WageHeader.pluck("header")
      form_headers = spreadsheet.row(1)
      n = 0
      form_headers.each do |fh|
        n += 1
        if !wage_headers.include?(fh)
          wage_import_message["head"] = "您上传的工资表第#{n}列表头名‘#{fh}’与系统不匹配，请前往修改！"
        end
      end

      wage_year_month_array = Wage.pluck("year","month").uniq
			if wage_year_month_array.include?([year.to_i,month.to_i])
				wage_import_message["year_month"] = "#{year}年#{month}月工资表已上传过，请勿重复上传！"
			end

      if !wage_import_message["head"].present? && !wage_import_message["year_month"].present?
  	    header_ids = (1..WageHeader.count).map{|m| "col"+ m.to_s}
  	    header_hash = [wage_headers,header_ids].transpose.to_h
        # bonus_headers = BonusHeader.pluck("header")
        # bonus_ids = BonusHeader.pluck("id").map{|m| "col"+ m.to_s}
        # bonus_header_hash = [bonus_headers,bonus_ids].transpose.to_h
  	    header = form_headers.map{|i| header_hash[i]}

  	    (2..spreadsheet.last_row).each do |j|
  	        row = Hash[[header, spreadsheet.row(j)].transpose]
            wage = Wage.new
  	        if Employee.find_by(:sal_number => row[header_hash["工资号"]]).present?
  	        	employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).id
  	        	wage.employee_id = employee_id
						end
            wage.year = year.to_i
            wage.month = month.to_i
            ["工资总额","基本工资","绩效工资","津贴补贴","岗位工资","技能工资","加班工资","主业工资"].each do |name|
              formula = WageHeader.find_by(:header => name).formula
              row[header_hash[name]] = 0.0
              if formula.present?
                formula.keys.each do |key|
                  if formula[key].to_i == 1
                    row[header_hash[name]] = (row[header_hash[name]].to_f + row[key].to_f)
                  elsif formula[key].to_i == 2
                    row[header_hash[name]] = (row[header_hash[name]].to_f - row[key].to_f)
                  end
                end
              end
            end
            wage.attributes = row
  	        wage.save!
  	    end
      end

      return wage_import_message
	end
end
