class AddFreelanceColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :user_profiles, :is_freelance, :boolean
    add_column :user_profiles, :company_name, :string
  end
end
