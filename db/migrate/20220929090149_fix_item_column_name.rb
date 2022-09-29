class FixItemColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :title, :item_name
  end
end
