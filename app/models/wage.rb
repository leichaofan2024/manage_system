class Wage < ApplicationRecord

scope :total_wage, -> { where.not(:id => LeavingEmployee.where(:leaving_type => "调离").pluck("employee_id"))}
  def self.head_transfer
    wage_header_hash = Hash.new
     WageHeader.all.each do |wage_header|
       key = "col"+wage_header.id.to_s
       wage_header_hash[key] = wage_header.header
     end
		 return wage_header_hash
	end


	def self.import_table(file,year,month)
      wage_import_message = Hash.new
	    spreadsheet = Roo::Spreadsheet.open(file.path)
	    # header_name = spreadsheet.row(1)
      # header_name += ["工资总额","奖金","基本工资","绩效工资","津贴补贴"]
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
	    header_ids = WageHeader.pluck("id").map{|m| "col"+ m.to_s}
	    header_hash = [wage_headers,header_ids].transpose.to_h
      # bonus_headers = BonusHeader.pluck("header")
      # bonus_ids = BonusHeader.pluck("id").map{|m| "col"+ m.to_s}
      # bonus_header_hash = [bonus_headers,bonus_ids].transpose.to_h
	    header = form_headers.map{|i| header_hash[i]}

	    (2..spreadsheet.last_row).each do |j|
	        row = Hash[[header, spreadsheet.row(j)].transpose]

          wage = Wage.new
	        if employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).present?
	        	employee_id = Employee.find_by(:sal_number => row[header_hash["工资号"]]).id
	        	wage.employee_id = employee_id
	        end
          wage.year = year.to_i
          wage.month = month.to_i
          # bonus_month = Bonu.find_by(:year => year,:month => month)
          #
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

          row[header_hash["基本工资"]] = row[header_hash["技能"]]
                                     - row[header_hash["岗位"]]
                                     - row[header_hash["增资"]]

          row[header_hash["津贴补贴"]] = row[header_hash["工龄"]]
                                     + row[header_hash["夜班费"]]
                                     + row[header_hash["生活补贴"]]
                                     + row[header_hash["增效"]]
                                     + row[header_hash["交通费"]]
                                     + row[header_hash["卫生费"]]
                                     + row[header_hash["房补"]]
                                     + row[header_hash["回民补贴"]]
                                     + row[header_hash["干部职贴"]]
                                     + row[header_hash["工人津贴"]]
                                     + row[header_hash["一线津贴"]]
                                     + row[header_hash["特种工资"]]
                                     + row[header_hash["工伤待遇"]]
                                     + row[header_hash["最低工资"]]
                                     + row[header_hash["它补1"]]
                                     + row[header_hash["它补2"]]
                                     + row[header_hash["高温津贴"]]


          wage.attributes = row

	        wage.save!
	    end

      return wage_import_message
	end
end
