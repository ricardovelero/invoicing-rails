# frozen_string_literal: true

# Line items already snapshot price/iva/total (see AddPriceIvaTotalToLineItems)
# but never snapshotted the item's name, so an issued invoice's PDF still read
# Item#item_name live. Backfilling with raw SQL rather than the models, same
# reasoning as RepairSequenceCountersBehindTheirSeries: a data migration has no
# business depending on model code that can change out from under it later.
class AddItemNameToLineItems < ActiveRecord::Migration[8.1]
  def up
    add_column :line_items, :item_name, :string

    execute <<~SQL.squish
      UPDATE line_items
         SET item_name = items.item_name
        FROM items
       WHERE items.id = line_items.item_id
    SQL

    change_column_null :line_items, :item_name, false
  end

  def down
    remove_column :line_items, :item_name
  end
end
