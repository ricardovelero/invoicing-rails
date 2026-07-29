# frozen_string_literal: true

# An invoice that has left Draft must carry a Scope and a Number. The reverse
# is deliberately not enforced: Issue writes the Number while the row is still
# a draft, so a numbered draft is a valid state inside that transaction.
class AddIssuedInvoicesAreNumberedConstraint < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :invoices,
                         "status = 'borrador' OR (series_id IS NOT NULL AND number IS NOT NULL)",
                         name: 'issued_invoices_are_numbered'
  end
end
