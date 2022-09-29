class FixClientColumnNames < ActiveRecord::Migration[7.0]
  def change
    rename_column :clients, :name, :first_name
    rename_column :clients, :lastname, :last_name
  end
end
