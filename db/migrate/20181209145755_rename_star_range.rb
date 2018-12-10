class RenameStarRange < ActiveRecord::Migration[5.1]
  def change
  	rename_column :star_ranges, :type, :range_type
  end
end
