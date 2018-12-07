class CreateStarInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :star_infos do |t|
      t.integer :basic_score_id
      t.integer :year
      t.integer :quarter
      t.string :workshop
      t.string :group
      t.string :name
      t.string :sal_number
      t.string :duty
      t.float :final_score, default: 0.0
      t.string :star
      t.timestamps
    end
  end
end
