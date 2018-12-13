class AddColumnTeamLeaderToStarInfoes < ActiveRecord::Migration[5.1]
  def change
  	add_column :star_infos,:team_leader,:boolean,default: false 
  end
end
