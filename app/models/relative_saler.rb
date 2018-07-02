class RelativeSaler < ApplicationRecord
  cattr_accessor :current_user

  belongs_to :user, optional: true
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        saler = find_by(id: row["id"]) || new
        saler.attributes = row.to_hash
        saler.update_attribute(:user_id, current_user.id)
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
