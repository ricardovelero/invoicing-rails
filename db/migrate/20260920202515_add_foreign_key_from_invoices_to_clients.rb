# frozen_string_literal: true

# invoices.client_id has never had a database-level foreign key, so a stale or
# forged client_id could persist a dangling invoice that only fails later, at
# render time, in Invoice#client_full_name / #pdf. Client already blocks
# deletion while invoices reference it (has_many :invoices,
# dependent: :restrict_with_error), so this constraint should never reject a
# legitimate write -- it closes the gap for paths that bypass that callback.
class AddForeignKeyFromInvoicesToClients < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :invoices, :clients
  end
end
