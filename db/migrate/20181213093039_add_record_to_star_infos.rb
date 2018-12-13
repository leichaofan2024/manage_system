class AddRecordToStarInfos < ActiveRecord::Migration[5.1]
  def change
  	add_column :star_infos, :descend_record, :integer, default: 0
  end
end
