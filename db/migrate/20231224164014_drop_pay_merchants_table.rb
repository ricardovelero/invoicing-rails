class DropPayMerchantsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :pay_merchants, force: :cascade
  end
end
