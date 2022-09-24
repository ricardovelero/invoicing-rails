json.extract! client, :id, :name, :lastname, :nif, :street, :city, :region, :postal_code, :country, :email, :telephone, :active, :created_at, :updated_at
json.url client_url(client, format: :json)
