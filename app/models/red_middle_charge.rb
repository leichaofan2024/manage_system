class RedMiddleCharge < ApplicationRecord

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        saler = find_by(id: row["id"]) || new
        saler.attributes = row.to_hash
        saler.save!
    end
  end

end
