class AddColumnLeavingCategoryToLeavingEmployees < ActiveRecord::Migration[5.1]
  def change
    add_column :leaving_employees,:category_id,:integer
  end
end
