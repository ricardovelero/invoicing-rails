class AddEmailColumnUserProfile < ActiveRecord::Migration[7.0]
  def change
    add_column(:user_profiles, :email, :string)
  end
end
