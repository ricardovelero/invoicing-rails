class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items do |t|
      t.references :item, null: false, foreign_key: true
      t.belongs_to :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
