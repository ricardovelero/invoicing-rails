class CreateInvoiceSeries < ActiveRecord::Migration[7.2]
  def change
    create_table :invoice_series do |t|
      t.references :user, null: false, foreign_key: true
      t.string :prefix, null: false

      t.timestamps
    end

    add_index :invoice_series, %i[user_id prefix], unique: true
  end
end
