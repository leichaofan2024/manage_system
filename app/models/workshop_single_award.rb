class WorkshopSingleAward < ApplicationRecord
  def self.import_form(file, upload_time,name)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    year = upload_time.split("-")[0].to_i
    month = upload_time.split("-")[1].to_i
    head_hash = OtherAwardTotalsHead.pluck(:name,:col_name).uniq.to_h
    import_head_hash = Hash.new
    import_head_hash["序号"] = "序号"
    import_head_hash["科室车间"] = "科室车间"
    import_head_hash["班组"] = "班组"
    import_head_hash["工资号"] = "工资号"
    import_head_hash["姓名"] = "姓名"
    import_head_hash["备注"] = "备注"
    import_head_hash["单项奖"] = head_hash[name]

    import_form_headers = spreadsheet.row(1)
    diff_head_name_array = Array.new
    import_form_headers.each do |head_name|
      if !import_head_hash.keys.include?(head_name)
         message[:head] = "所上传的单项奖明细表表头为‘#{head_name}’的字段与系统不匹配，请核对更正后再上传！"
      end
    end
    if message.blank?
      # 解析exsl表头时转化后的表头，与其他单项奖汇总表表头对应：
      import_keys = import_form_headers.map{|head| import_head_hash[head]}

      (2..spreadsheet.last_row).each do |n|
        row_hash = [import_keys,spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        workshop_single_award = WorkshopSingleAward.find_by(:upload_year => year,:upload_month => month,:工资号 => row_hash["工资号"])
        if workshop_single_award.present?
          workshop_single_award.update(import_head_hash["单项奖"] => row_hash[import_head_hash["单项奖"]])
        else
          WorkshopSingleAward.create(row_hash)
        end
      end
    end
    return message
  end
end
