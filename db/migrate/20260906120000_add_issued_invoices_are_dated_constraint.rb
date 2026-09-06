# frozen_string_literal: true

# Companion to issued_invoices_are_numbered: an invoice that has left Draft
# must also carry both of its dates. Without this an invoice could be issued
# with no date, taking a Number that no view and no PDF could ever render and
# that no edit could repair, because both dates freeze on issue.
class AddIssuedInvoicesAreDatedConstraint < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :invoices,
                         "status = 'borrador' OR (date IS NOT NULL AND due_date IS NOT NULL)",
                         name: 'issued_invoices_are_dated'
  end
end
