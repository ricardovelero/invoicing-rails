class RemoveFirstAndLastNameUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column(:users, :first_name)
    remove_column(:users, :last_name)
  end
end
