class RemoveNotFalseToReference < ActiveRecord::Migration[7.0]
  def change
    change_column :user_profiles, :user_id, :bigint, null: true
  end
end
