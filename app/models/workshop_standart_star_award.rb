class WorkshopStandartStarAward < ApplicationRecord
  def self.import_form(file, upload_time,name)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    year = upload_time.split("-")[0].to_i
    month = upload_time.split("-")[1].to_i
    form_column = WorkshopStandartStarAward.column_names-["标准化","星级岗"]

    import_form_headers = spreadsheet.row(1)
    (import_form_headers-["单项奖"]).each do |head_name|
      if !form_column.include?(head_name)
         message[:head] = "所上传的单项奖明细表表头为‘#{head_name}’的字段与系统不匹配，请核对更正后再上传！"
      end
    end

    # 先验证劳资有没有上传"标准化"或"星级岗"汇总表：
    if name == "标准化"
      befor_import = StandardAwardTotal.where(:upload_year =>year,:upload_month => month)
    elsif name == "星级岗"
      befor_import = StarAward.where(:upload_year =>year,:upload_month => month)
    end
    if !befor_import.present?
      message[:after_total] = "劳资尚未上传“#{name}”汇总表，请等劳资上传后再操作！"
    end
    # 劳资本月上传"标准化"或"星级岗"汇总表中的所有科室车间名称：
    workshop_names = befor_import.pluck(:科室车间).uniq

    # 科室车间上传的"标准化"或"星级岗"明细表中的科室或车间名：
    workshop_name = [spreadsheet.row(1),spreadsheet.row(2)].transpose.to_h["科室车间"]
    if !workshop_names.include?(workshop_name)
      message[:workshop_name] = "您上传的工挂工资明细表中的科室或车间名与劳资上传的汇总表里的科室或车间名称不一样，请核对、更正后再上传！"
    end

    if message.blank?
      array_index = import_form_headers.index("单项奖")
      import_form_headers[array_index] = name
      import_keys = import_form_headers
      (2..spreadsheet.last_row).each do |n|
        row_hash = [import_keys,spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        workshop_single_award = WorkshopStandartStarAward.find_by(:upload_year => year,:upload_month => month,:工资号 => row_hash["工资号"])
        if workshop_single_award.present?
          workshop_single_award.update(name => row_hash[name])
        else
          WorkshopStandartStarAward.create(row_hash)
        end
      end

      message[:value_match] = Array.new
      # 本科室、车间单项奖汇总表信息：
      award_total = befor_import.find_by(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name)
      award_total_hash = award_total.attributes
      # 本月本科室、车间上传的单项奖明细表信息：
      workshop_single_awards = WorkshopStandartStarAward.where(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name)

      if workshop_single_awards.sum(name).to_f != award_total_hash[name].to_f
        message[:value_match] << name
      end
      if message[:value_match].present?
        workshop_single_awards.delete_all
      end
    end
    return message
  end
end
