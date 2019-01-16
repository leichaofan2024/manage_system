class WorkshopSingleAward < ApplicationRecord
  def self.import_form(file, upload_time,name)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)

    # 科室车间上传的工挂明细表中的科室或车间名：
    workshop_index = (spreadsheet.row(1)).index("科室车间")
    workshop_name_array = Array.new
    (2..spreadsheet.last_row).each do |n|
      workshop_name_array << (spreadsheet.row(n))[workshop_index]
    end
    workshop_name = workshop_name_array.uniq

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
    workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name)
    if !workshop_relative_salers.present?
      message[:no_workshop_relative_saler] = "您还没有上传#{month}月工挂工资明细表，请现上传后再传单项奖表！"
    end 
    # 劳资本月上传汇总表中的所有科室车间名称：
    workshop_names = OtherAwardTotal.where(:upload_year =>year,:upload_month => month).pluck(:科室车间).uniq
    diff_names = Array.new
    workshop_name.each do |x|
      if !workshop_names.include?(x)
        diff_names << 1
      end
    end

    if workshop_name.count != (workshop_name.compact.count)
      message[:workshop_name] = "您上传的单项奖明细表中的科室或车间名不能为空，请核对、更正后再上传！"
    elsif diff_names.present?
      message[:workshop_name] = "科室或车间名要与劳资上传的单项奖汇总表里的科室或车间名称保持一致，请核对、更正后再上传！"
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

      message[:value_match] = Array.new
      workshop_name.each do |every_name|
        # 本科室、车间工效挂钩工资汇总表信息：
        other_award_total = OtherAwardTotal.find_by(:upload_year =>year,:upload_month => month,:科室车间 => every_name)
        other_award_total_hash = other_award_total.attributes
        # 本次上传的工效挂钩明细表信息：
        workshop_single_awards = WorkshopSingleAward.where(:upload_year =>year,:upload_month => month,:科室车间 => every_name)

        if workshop_single_awards.sum(head_hash[name]).to_f != other_award_total_hash[head_hash[name]].to_f
          message[:value_match] << name
        end
      end

      if message[:value_match].present?
        WorkshopSingleAward.where(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name).delete_all
      end


    end
    return message
  end
end
