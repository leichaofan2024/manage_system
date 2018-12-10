class BasicScore < ApplicationRecord
	def self.import_table(file,workshop,year,quarter)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      import_form_head = spreadsheet.row(1)
      basic_form_head = BasicScore.columns 
      message = Hash.new
      import_form_head.each do |import_head| 
      	if !basic_form_head.include?(import_head)
          message[:head] = "表头《#{import_head}》与系统不匹配，请更正后再上传！"
      	end 
      end 
      year_quarter_already = BasicScore.find_by(:workshop => workshop,:year => year,:quarter => quarter)
      if year_quarter_already.present?
        message[:year_quarter] = "#{workshop}#{year}年第#{quarter}季度考勤汇总表已存在，请勿重复上传！" 
      end 
      if message.blank?
      	
        (2..spreadsheet.last_row).each do |n|
        	spreadsheet.row(n)
        end 
      end 
	end 
end
