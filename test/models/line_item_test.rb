# frozen_string_literal: true

require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  test 'snapshots item name, price and iva when the item is assigned' do
    item = items(:first)
    invoice = invoices(:draft_one)
    quantity = 2
    total = item.price * quantity * (1 + item.iva / 100)
    line_item = LineItem.create!(item:, invoice:, quantity:, total:)

    assert_equal item.item_name, line_item.item_name
    assert_equal item.price, line_item.price
    assert_equal item.iva, line_item.iva
  end

  test "later changes to the item do not change an existing line item's snapshot" do
    line_item = line_items(:one)
    original_item_name = line_item.item_name
    original_price = line_item.price
    original_iva = line_item.iva

    line_item.item.update!(item_name: 'Renamed item', price: 1, iva: 4)

    line_item.reload
    assert_equal original_item_name, line_item.item_name
    assert_equal original_price, line_item.price
    assert_equal original_iva, line_item.iva
  end

  test "sub_total, total_price and total_iva use the line item's own snapshot, not the live item" do
    line_item = line_items(:one)
    expected_sub_total = line_item.sub_total
    expected_total_price = line_item.total_price
    expected_total_iva = line_item.total_iva

    line_item.item.update!(price: 1, iva: 4)

    assert_equal expected_sub_total, line_item.sub_total
    assert_equal expected_total_price, line_item.total_price
    assert_equal expected_total_iva, line_item.total_iva
  end
end
