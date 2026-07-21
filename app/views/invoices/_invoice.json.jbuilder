json.extract! invoice,
              :id,
              :date,
              :due_date,
              :subtotal,
              :iva,
              :irpf,
              :total,
              :notes,
              :status,
              :created_at,
              :updated_at
json.number invoice.display_number
json.url invoice_url(invoice, format: :json)
