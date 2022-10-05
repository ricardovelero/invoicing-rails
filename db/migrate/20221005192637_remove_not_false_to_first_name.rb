class RemoveNotFalseToFirstName < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :first_name, :string, null: true
  end
end
