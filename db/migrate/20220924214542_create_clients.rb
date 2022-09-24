class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :lastname
      t.string :nif
      t.string :street
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country
      t.string :email
      t.string :telephone
      t.boolean :active

      t.timestamps
    end
  end
end
