class AddColumnFormulaToBonusHeader < ActiveRecord::Migration[5.1]
  def change
    add_column :bonus_headers, :formula, :json
  end
end
