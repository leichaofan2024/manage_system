class ChargeDetail < ApplicationRecord

  def self.import(file, upload_time)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        saler = find_by(id: row["id"]) || new
        saler.attributes = row.to_hash
        year = upload_time.split("-")[0]
        month = upload_time.split("-")[1]
        saler.upload_year = year
        saler.upload_month = month
        saler.save!
    end
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
