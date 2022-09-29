class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :title
      t.text :description
      t.decimal :price, precision: 8, scale: 2
      t.decimal :iva
      t.decimal :irpf

      t.timestamps
    end
  end
end
