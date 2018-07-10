class Wage < ApplicationRecord

scope :total_wage, -> { where.not(:id => LeavingEmployee.where(:leaving_type => "调离").pluck("employee_id"))}

	def self.import_table(file)
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    # header = spreadsheet.row(1)
	    # header.each do |i|
	    # 	WageHeader.create(:header => i)
	    # end

		wage_headers = WageHeader.pluck("header")
	    header_ids = WageHeader.pluck("id")
	    header_hash = {}
	    header_count = WageHeader.all.count - 1
	    (0..header_count).each do |i|
	      header_hash[wage_headers[i]] = header_ids[i]
	    end
	    header = spreadsheet.row(1).map{|i| "col" +  header_hash[i].to_s}
	    (2..spreadsheet.last_row).each do |j|
	        row = Hash[[header, spreadsheet.row(j)].transpose]	        
	        e = "col" + WageHeader.find_by(header: "工资号").id.to_s
	        wage = find_by("#{e}": row[e]) || new
	        wage.attributes = row
	        if employee_id = Employee.find_by(:sal_number => row[e]).present?
	        	employee_id = Employee.find_by(:sal_number => row[e]).id
	        	wage.employee_id = employee_id
	        end
	        wage.save!
	    end
	end
end
