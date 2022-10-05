class AddUserProfileToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :user_profile, foreign_key: true
  end
end
