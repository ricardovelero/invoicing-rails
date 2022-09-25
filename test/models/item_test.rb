require "test_helper"

class ItemTest < ActiveSupport::TestCase
  fixtures :items
  test "item attributes must not be empty" do
    item = Item.new
    assert item.invalid?
    assert item.errors[:title].any?
    assert item.errors[:price].any?
  end

  test "item price must be positive" do
    item = Item.new(title: "Test Item", description: "This is a test")

    item.price = -1
    assert item.invalid?
    assert_equal ["must be greater than or equal to 0.01"], item.errors[:price]

    item.price = 0
    assert item.invalid?
    assert_equal ["must be greater than or equal to 0.01"], item.errors[:price]

    item.price = 1
    assert item.valid?
  end

  test "item is not valid without a unique title" do
    item =
      Item.new(
        title: items(:item).title,
        description: "yyy",
        price: 1,
        tax1: 21,
        tax2: 4
      )
    assert item.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], item.errors[:title]
  end
end
