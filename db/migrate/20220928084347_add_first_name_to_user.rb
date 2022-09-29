class AddFirstNameToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string, null: false
    add_column :users, :last_name, :string, default: ""
  end
end
