class FixItemTaxColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :iva, :iva
    rename_column :items, :irpf, :irpf
  end
end
