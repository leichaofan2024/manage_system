class AddColumnFormulaToWageHeaders < ActiveRecord::Migration[5.1]
  def change
    add_column :wage_headers,:formula,:json
  end
end
