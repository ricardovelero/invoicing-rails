class RemoveIrpfColumnItem < ActiveRecord::Migration[7.0]
  def change
    remove_column(:items, :irpf)
  end
end
