require "test_helper"

class ItemTest < ActiveSupport::TestCase
  # fixtures :items
  test "should not save item without name" do
    item = Item.new
    assert_not item.save, "Saved the article without a title"
  end

  test "item attributes must not be empty" do
    item = Item.new
    assert item.invalid?
    assert item.errors[:item_name].any?
    assert item.errors[:price].any?
  end

  test "item price must be positive" do
    item = Item.new(item_name: "Price Test", description: "Test for negative price", iva:10)
    item.price = -1
    assert item.invalid?
    assert item.errors[:price].any?

    item = Item.new(item_name: "Price Test", description: "Test for zero price", iva:21)
    item.price = 0
    assert item.invalid?
    assert_not item.errors[:price].any?

    item = Item.new(item_name: "Price Test", description: "Test for positive price", iva:21)
    item.price = 1
    assert item.invalid?
    assert_not item.errors[:price].any?

  end
  test "iva must be positive" do
    item = Item.new(item_name: "IVA Test", description: "Test for negative iva", price:10)
    item.iva = -1
    assert item.invalid?
    assert item.errors[:iva].any?

    item = Item.new(item_name: "IVA Test", description: "Test for zero iva", price:21)
    item.iva = 0
    assert item.invalid?
    assert_not item.errors[:iva].any?

    item = Item.new(item_name: "IVA Test", description: "Test for positive iva", price:21)
    item.iva = 1
    assert item.invalid?
    assert_not item.errors[:iva].any?

  end  
  test "item is not valid without a unique name" do
    item =
      Item.new(
        item_name: items(:first).item_name,
        description: "yyy",
        price: 1,
        iva: 21
      )
    assert item.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], item.errors[:item_name]
  end
end
