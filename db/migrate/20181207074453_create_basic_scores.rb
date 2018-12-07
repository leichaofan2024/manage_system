class CreateBasicScores < ActiveRecord::Migration[5.1]
  def change
    create_table :basic_scores do |t|
      t.integer :year
      t.integer :quarter
      t.string :workshop
      t.string :group
      t.string :name
      t.string :sal_number
      t.string :duty
      t.float :theory_score, default: 0.0
      t.float :theory_weighted_score, default: 0.0
      t.float :practical_score, default: 0.0
      t.float :practical_weighted_score, default: 0.0
      t.float :work_performance, default: 0.0
      t.float :work_performance_weighted_score, default: 0.0
      t.float :extra_score, default: 0.0
      t.string :extra_score_reason
      t.float :final_score, default: 0.0
      t.string :team_leader
      t.boolean :confirm_status, default: 0
      t.timestamps
    end
  end
end
