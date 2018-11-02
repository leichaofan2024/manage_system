class WorkshopRelativeSaler < ApplicationRecord
  def self.import_form(file,upload_time)
    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    import_form_headers = spreadsheet.row(1)
    form_headers = WorkshopRelativeSaler.column_names
    import_form_headers.each do |fh|
      if !form_headers.include?(fh)
        message[:head] = "所上传的工挂工资明细表表头为‘#{fh}’的字段与系统不匹配，请核对后再上传！"
      end
    end
    year_month_already_import = WorkshopRelativeSaler.pluck(:upload_year,:upload_month).uniq
    year = upload_time.split("-")[0].to_i
    month = upload_time.split("-")[1].to_i
    if year_month_already_import.include?([year.to_s,month.to_s])
      message[:year_month] = "本月数据已上传，请勿重复上传！"
    end

    # 先验证劳资有没有上传功效挂钩汇总表：
    relative_saler_totals = RelativeSalersTotal.where(:upload_year =>year,:upload_month => month)
    if !relative_saler_totals.present?
      message[:after_total] = "劳资尚未上传工效挂钩汇总表，请等劳资上传后再操作！"
    end
    # 劳资本月上传汇总表中的所有科室车间名称：
    workshop_names = relative_saler_totals.pluck(:科室车间).uniq

    # 科室车间上传的工挂明细表中的科室或车间名：
    workshop_name = [spreadsheet.row(1),spreadsheet.row(2)].transpose.to_h["科室车间"]
    if !workshop_names.include?(workshop_name)
      message[:workshop_name] = "您上传的工挂工资明细表中的科室或车间名与劳资上传的汇总表里的科室或车间名称不一样，请核对、更正后再上传！"
    end

    if message.blank?
      (2..spreadsheet.last_row).each do |n|
        row_hash = [spreadsheet.row(1),spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        WorkshopRelativeSaler.create(row_hash)
      end
      message[:value_match] = Array.new
      # 本科室、车间工效挂钩工资汇总表信息：
      relative_saler_total = RelativeSalersTotal.find_by(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name)
      relative_saler_total_hash = relative_saler_total.attributes
      # 本次上传的工效挂钩明细表信息：
      workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year =>year,:upload_month => month,:科室车间 => workshop_name)
      ["挂钩工资","安全质量","工作质量","行车","整改返奖","一体化","兼职兼岗","考核扣款","其他","应发","小计"].each do |name|
        if workshop_relative_salers.sum(name).to_f != relative_saler_total_hash[name].to_f
          message[:value_match] << name
        end
      end
      if message[:value_match].present?
        workshop_relative_salers.delete_all
      end

    end

    return message
  end

end
