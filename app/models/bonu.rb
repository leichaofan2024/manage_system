class Bonu < ApplicationRecord
	def self.import_table(file,year,month)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    # header = spreadsheet.row(1)
	    # header.each do |i|
	    # 	BonusHeader.create(:header => i)
	    # end

	    bonus_headers = BonusHeader.pluck("header")
			form_headers = spreadsheet.row(1)
			n = 0
      form_headers.each do |fh|
        n += 1
        if !bonus_headers.include?(fh)
          bonus_import_message["head"] = "您上传的工资表第#{n}列表头名‘#{fh}’与系统不匹配，请前往修改！"

        end
      end
			if !wage_import_message["head"].present?
		    header_ids = BonusHeader.pluck("id").map{|h| "col"+ h.to_s}
		    header_hash = Hash[[bonus_headers,header_ids].transpose]
		    header = form_headers.map{|i| header_hash[i]}
		    (2..spreadsheet.last_row).each do |j|
		        row = Hash[[header, spreadsheet.row(j)].transpose]
		        e = "工资号"
		        bonus = find_by("#{e}": row[e]) || new
		        bonus.attributes = row
		        if employee_id = Employee.find_by(:sal_number => row[e]).present?
		        	employee_id = Employee.find_by(:sal_number => row[e]).id
		        	bonus.employee_id = employee_id
		        end
		        bonus.save!
		    end
      end
			return bonus_import_message
	end
end
