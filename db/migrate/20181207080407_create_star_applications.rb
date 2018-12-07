class CreateStarApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :star_applications do |t|
      t.integer :star_info_id
      t.integer :up_down_star
      t.string :applicant
      t.boolean :status, default: false
      t.timestamps
    end
  end
end
