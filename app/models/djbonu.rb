class Djbonu < ApplicationRecord
  def self.head_transfer
    djbonus_headers = DjbonusHeader.pluck("header")
    header_ids = (1..DjbonusHeader.count).map{|m| "col"+ m.to_s}
    header_hash = [header_ids,djbonus_headers].transpose.to_h
		return header_hash
	end

  def self.import_table(file,year,month)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    header = spreadsheet.row(1)
      # header += ["多经奖金"]
	    # header.each do |i|
	    # 	DjbonusHeader.create(:header => i)
	    # end

			djbonus_import_message = Hash.new
	    djbonus_headers = DjbonusHeader.pluck("header")
			form_headers = spreadsheet.row(1)
			n = 0
      form_headers.each do |fh|
        n += 1
        if !djbonus_headers.include?(fh)
          djbonus_import_message["head"] = "您上传的奖金表第#{n}列表头名‘#{fh}’与系统不匹配，请前往修改！"
        end
      end

			djbonus_year_month_array = Djbonu.pluck("year","month").uniq
			if djbonus_year_month_array.include?([year.to_i,month.to_i])
				djbonus_import_message["year_month"] = "#{year}年#{month}月奖金表已上传过，请勿重复上传！"
			end

			if !djbonus_import_message["head"].present? && !djbonus_import_message["year_month"].present?
				(1..(DjbonusHeader.count))
		    header_ids = (1..(DjbonusHeader.count)).map{|h| "col"+ h.to_s}
		    header_hash = Hash[[djbonus_headers,header_ids].transpose]
		    header = form_headers.map{|i| header_hash[i]}
		    (2..spreadsheet.last_row).each do |j|
		        row = Hash[[header, spreadsheet.row(j)].transpose]
						djbonu = Djbonu.new
  	        if Employee.find_by(:sal_number => row[header_hash["工资号"]]).present?
  	        	employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).id
  	        	djbonu.employee_id = employee_id
						end
            djbonu.year = year.to_i
            djbonu.month = month.to_i

            formula = DjbonusHeader.find_by(:header => "多经奖金").formula
            row[header_hash["多经奖金"]] = 0
            if formula.present?
              formula.keys.each do |key|
                if formula[key].to_i == 1
                  row[header_hash["多经奖金"]] = (row[header_hash["多经奖金"]].to_f + row[key].to_f)
                elsif formula[key].to_i == 2
                  row[header_hash["多经奖金"]] = (row[header_hash["多经奖金"]].to_f - row[key].to_f)
                end
              end
            end

		        djbonu.attributes = row
		        djbonu.save!
		    end
      end

			return djbonus_import_message
	end
end
