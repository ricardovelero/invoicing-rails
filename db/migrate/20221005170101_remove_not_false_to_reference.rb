class RemoveNotFalseToReference < ActiveRecord::Migration[7.0]
    change_column :user_profiles, :user_id, :bigint, null: true
  def change
  end
end
