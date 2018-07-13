class ExaminationCharge < ApplicationRecord

  def self.import(file, upload_time)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        saler = find_by(id: row["id"]) || new
        saler.attributes = row.to_hash
        saler.upload_year = upload_time.split("-")[0]
        saler.upload_month = upload_time.split("-")[1]
        saler.save!
    end
  end

end
