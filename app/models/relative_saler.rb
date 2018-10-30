class RelativeSaler < ApplicationRecord
  cattr_accessor :current_user

  belongs_to :user, optional: true

  def self.import_form(file, upload_time)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    import_form_headers = spreadsheet.row(1)
    form_headers = RelativeSaler.column_names
    import_form_headers.each do |fh|
      if !form_headers.include?(fh)
        message[:head] = "所上传的工挂工资明细表表头为‘#{fh}’的字段与系统不匹配，请核对后再上传！"
      end
    end
    year_month_already_import = RelativeSaler.pluck(:upload_year,:upload_month).uniq
    year = upload_time.split("-")[0].to_s
    month = upload_time.split("-")[1].to_s
    if year_month_already_import.include?([year,month])
      message[:year_month] = "本月数据已上传，请勿重复上传！"
    end

    if message.blank?
      (2..spreadsheet.last_row).each do |n|
        row_hash = [spreadsheet.row(1),spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        RelativeSaler.create(row_hash)

      end
    end
    return message
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end


end
