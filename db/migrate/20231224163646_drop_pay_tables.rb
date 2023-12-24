class DropPayTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :pay_webhooks
    drop_table :pay_subscriptions, force: :cascade
    drop_table :pay_payment_methods
    drop_table :pay_customers, force: :cascade
    drop_table :pay_charges
  end
end
