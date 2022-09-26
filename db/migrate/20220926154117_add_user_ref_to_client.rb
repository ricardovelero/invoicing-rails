class AddUserRefToClient < ActiveRecord::Migration[7.0]
  def change
    add_reference :clients, :user, null: false, foreign_key: true
  end
end
