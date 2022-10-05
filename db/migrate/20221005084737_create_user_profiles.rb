class CreateUserProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_profiles do |t|
      t.string :gov_id
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country
      t.string :phone
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
