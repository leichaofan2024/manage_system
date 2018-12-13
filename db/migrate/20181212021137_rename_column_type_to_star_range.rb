class RenameColumnTypeToStarRange < ActiveRecord::Migration[5.1]
  def change
  	rename_column :star_ranges,:type,:f_type
  end
end
