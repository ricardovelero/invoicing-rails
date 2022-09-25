require "test_helper"

class ItemTest < ActiveSupport::TestCase
  fixtures :items
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
end
