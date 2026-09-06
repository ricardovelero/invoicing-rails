# frozen_string_literal: true

# The pay gem's own migrations created these tables, and the gem was removed
# with them, so on a database built from zero the tables never exist and the
# bare drops raised PG::UndefinedTable. Guarded rather than emptied: a database
# that still carries them must still have them dropped.
class DropPayTables < ActiveRecord::Migration[7.1]
  TABLES = { pay_webhooks: {}, pay_subscriptions: { force: :cascade },
             pay_payment_methods: {}, pay_customers: { force: :cascade },
             pay_charges: {} }.freeze

  def up
    TABLES.each { |table, options| drop_table(table, **options) if table_exists?(table) }
  end

  # The gem that owned these tables is gone; nothing here can recreate them.
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
