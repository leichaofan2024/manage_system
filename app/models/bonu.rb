class Bonu < ApplicationRecord
	def self.import_table(file)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    # header = spreadsheet.row(1)
	    # header.each do |i|
	    # 	BonusHeader.create(:header => i)
	    # end

	    bonus_headers = BonusHeader.pluck("header")
	    header_ids = BonusHeader.pluck("id")
	    header_hash = {}
	    header_count = BonusHeader.all.count - 1
	    (0..header_count).each do |i|
	      header_hash[bonus_headers[i]] = header_ids[i]
	    end
	    header = spreadsheet.row(1).map{|i| "col" +  header_hash[i].to_s}
	    (2..spreadsheet.last_row).each do |j|
	        row = Hash[[header, spreadsheet.row(j)].transpose]	        
	        e = "col" + BonusHeader.find_by(header: "工资号").id.to_s
	        bonus = find_by("#{e}": row[e]) || new
	        bonus.attributes = row
	        if employee_id = Employee.find_by(:sal_number => row[e]).present?
	        	employee_id = Employee.find_by(:sal_number => row[e]).id
	        	bonus.employee_id = employee_id
	        end
	        bonus.save!
	    end
		
	end
end
