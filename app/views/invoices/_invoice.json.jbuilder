json.extract! invoice, :id, :number, :date, :due_date, :subtotal, :iva, :irpf, :total, :notes, :status, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
