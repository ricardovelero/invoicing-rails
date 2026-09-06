# frozen_string_literal: true

# See DropPayTables: the pay gem owned this table and went away with it.
class DropPayMerchantsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :pay_merchants, force: :cascade if table_exists?(:pay_merchants)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
