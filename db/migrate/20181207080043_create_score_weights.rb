class CreateScoreWeights < ActiveRecord::Migration[5.1]
  def change
    create_table :score_weights do |t|
      t.float :theory_score, default: 0.0
      t.float :practical_score, default: 0.0
      t.float :work_performance, default: 0.0
      t.timestamps
    end
  end
end
