class StandardGroup < ApplicationRecord

  def self.import_form(file, upload_time)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    import_form_headers = spreadsheet.row(1)
    form_headers = StandardGroup.column_names
    import_form_headers.each do |fh|
      if !form_headers.include?(fh)
        message[:head] = "所上传的标准化班组表表头为‘#{fh}’的字段与系统不匹配，请核对后再上传！"
      end
    end
    year_month_already_import = StandardGroup.pluck(:upload_year,:upload_month).uniq
    year = upload_time.split("-")[0].to_i
    month = upload_time.split("-")[1].to_i
    if year_month_already_import.include?([year.to_s,month.to_s])
      message[:year_month] = "本月数据已上传，请勿重复上传！"
    end

    if message.blank?
      (2..spreadsheet.last_row).each do |n|
        row_hash = [spreadsheet.row(1),spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        StandardGroup.create(row_hash)
      end
    end
    return message
  end

end
