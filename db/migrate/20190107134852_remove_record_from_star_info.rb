class RemoveRecordFromStarInfo < ActiveRecord::Migration[5.1]
  def change
  	remove_column :star_infos, :descend_record
  end
end
