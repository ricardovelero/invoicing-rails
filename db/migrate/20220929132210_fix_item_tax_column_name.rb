# frozen_string_literal: true

# Committed broken on 2022-09-29 (f55f504) and never able to run: it renamed
# :iva to :iva and :irpf to :irpf, which Postgres rejects as PG::DuplicateColumn.
# Its siblings that day were real renames (:title -> :item_name), but these two
# columns were already correctly named by CreateItems, so there was nothing to
# rename. Emptied rather than deleted, so databases that recorded this version
# stay consistent, and so `db:migrate` from zero can get past it.
class FixItemTaxColumnName < ActiveRecord::Migration[7.0]
  def change; end
end
