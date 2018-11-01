class OtherAwardTotal < ApplicationRecord

  def self.import_form(file, upload_time)

    message = Hash.new
    spreadsheet = Roo::Spreadsheet.open(file.path)
    year = upload_time.split("-")[0].to_i
    month = upload_time.split("-")[1].to_i
    # 本月不能重复上传：
    year_month_already_import_head = OtherAwardTotalsHead.pluck(:upload_year,:upload_month).uniq
    year_month_already_import = OtherAwardTotal.pluck(:upload_year,:upload_month).uniq
    if year_month_already_import.include?([year.to_s,month.to_s]) || year_month_already_import_head.include?([year.to_s,month.to_s])
      message[:year_month] = "本月数据已上传，请勿重复上传！"
    end

    import_form_headers = spreadsheet.row(1)
    import_award_heads = (import_form_headers - ["序号","科室车间","排名奖励","防止安全隐患奖励","备注"]).uniq
    already_have_heads = OtherAwardTotalsHead.pluck(:name).uniq
    award_head_hash = Hash.new
    award_head_hash["序号"] = "序号"
    award_head_hash["科室车间"] = "科室车间"
    award_head_hash["排名奖励"] = "排名奖励"
    award_head_hash["防止安全隐患奖励"] = "防止安全隐患奖励"
    award_head_hash["备注"] = "备注"

    if message.blank?
      # 创建本月其他单项奖表头：
      import_award_heads.each do |award_head|
        if already_have_heads.include?(award_head)
          col_name = OtherAwardTotalsHead.find_by(:name => award_head).col_name
          OtherAwardTotalsHead.create(:name => award_head,:col_name => col_name,:upload_year => year,:upload_month => month)
        else
          OtherAwardTotalsHead.create(:name => award_head,:col_name => ("col"+ (OtherAwardTotalsHead.pluck(:name).uniq.count + 1).to_s),:upload_year => year,:upload_month => month)
        end
        award_head_hash[award_head] = OtherAwardTotalsHead.find_by(:name => award_head).col_name
      end

      # 解析exsl表头时转化后的表头，与其他单项奖表头对应：
      import_keys = import_form_headers.map{|head| award_head_hash[head]}

      (2..spreadsheet.last_row).each do |n|
        row_hash = [import_keys,spreadsheet.row(n)].transpose.to_h
        row_hash[:upload_year] = year
        row_hash[:upload_month] = month
        OtherAwardTotal.create(row_hash)
      end
    end
    return message
  end

end
