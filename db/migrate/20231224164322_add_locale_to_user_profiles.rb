class AddLocaleToUserProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :user_profiles, :locale, :string
  end
end
