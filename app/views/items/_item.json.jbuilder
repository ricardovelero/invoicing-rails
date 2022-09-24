json.extract! item, :id, :title, :description, :price, :tax1, :tax2, :created_at, :updated_at
json.url item_url(item, format: :json)
