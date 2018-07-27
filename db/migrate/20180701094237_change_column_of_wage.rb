class ChangeColumnOfWage < ActiveRecord::Migration[5.1]
  def change
  	change_column :wages, :col4, :string
  	change_column :wages, :col5, :string
  	change_column :wages, :col6, :string
  	change_column :wages, :col7, :string
  	change_column :wages, :col8, :string
  	change_column :wages, :col9, :string
  	change_column :wages, :col10, :string
  	change_column :wages, :col11, :string
  	change_column :wages, :col12, :string
  end
end
