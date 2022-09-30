json.extract! item, :id, :item_name, :description, :price, :iva, :irpf, :created_at, :updated_at
json.url item_url(item, format: :json)
