class Djwage < ApplicationRecord
  def self.head_transfer
    djwage_headers = DjwageHeader.pluck("header")
    header_ids = (1..DjwageHeader.count).map{|m| "col"+ m.to_s}
    header_hash = [header_ids,djwage_headers].transpose.to_h
		return header_hash
	end

  def self.import_table(file,year,month)
      djwage_import_message = Hash.new
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    header_name = spreadsheet.row(1)
      # header_name += ["多经工资"]
	    # header_name.each do |i|
	    # 	DjwageHeader.create(:header => i.to_s)
	    # end

	  	djwage_headers = DjwageHeader.pluck("header")
      form_headers = spreadsheet.row(1)
      n = 0
      form_headers.each do |fh|
        n += 1
        if !djwage_headers.include?(fh)
          djwage_import_message["head"] = "您上传的多经工资表第#{n}列表头名‘#{fh}’与系统不匹配，请前往修改！"
        end
      end

      djwage_year_month_array = Djwage.pluck("year","month").uniq
			if djwage_year_month_array.include?([year.to_i,month.to_i])
				djwage_import_message["year_month"] = "#{year}年#{month}月多经工资表已上传过，请勿重复上传！"
			end

      if !djwage_import_message["head"].present? && !djwage_import_message["year_month"].present?
  	    header_ids = (1..DjwageHeader.count).map{|m| "col"+ m.to_s}
  	    header_hash = [djwage_headers,header_ids].transpose.to_h
  	    header = form_headers.map{|i| header_hash[i]}

  	    (2..spreadsheet.last_row).each do |j|
  	        row = Hash[[header, spreadsheet.row(j)].transpose]
            djwage = Djwage.new
  	        if Employee.find_by(:sal_number => row[header_hash["工资号"]]).present?
  	        	employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).id
  	        	djwage.employee_id = employee_id
						end
            djwage.year = year.to_i
            djwage.month = month.to_i
            formula = DjwageHeader.find_by(:header => "多经工资").formula
            row[header_hash["多经工资"]] = 0.0
            if formula.present?
              formula.keys.each do |key|
                if formula[key].to_i == 1
                  row[header_hash["多经工资"]] = (row[header_hash["多经工资"]].to_f + row[key].to_f)
                elsif formula[key].to_i == 2
                  row[header_hash["多经工资"]] = (row[header_hash["多经工资"]].to_f - row[key].to_f)
                end
              end
            end
            djwage.attributes = row
  	        djwage.save!
  	    end
      end

      return djwage_import_message
	end
end
