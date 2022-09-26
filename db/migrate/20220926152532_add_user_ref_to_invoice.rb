class AddUserRefToInvoice < ActiveRecord::Migration[7.0]
  def change
    add_reference :invoices, :user, null: false, foreign_key: true
  end
end
