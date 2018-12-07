class CreateFinalStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :final_statistics do |t|
      t.integer :year
      t.integer :quarter
      t.string :workshop
      t.integer :number_of_workers
      t.integer :five_star
      t.integer :four_star
      t.integer :three_star
      t.integer :two_star
      t.integer :one_star
      t.float :total_amount, default: 0.0
      t.integer :team_leader_five_star
      t.timestamps
    end
  end
end
