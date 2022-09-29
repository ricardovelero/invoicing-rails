json.extract! item, :id, :title, :description, :price, :iva, :irpf, :created_at, :updated_at
json.url item_url(item, format: :json)
