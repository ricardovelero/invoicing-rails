require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:first)
    @title = "Item test #{rand(100)}"
    sign_in users(:first)
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count") do
      post items_url,
           params: {
             item: {
               item_name: @title,
               description: @item.description,
               price: @item.price,
               iva: @item.iva
             }
           }
    end

    assert_redirected_to items_url(locale: I18n.locale)
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item),
          params: {
            item: {
              item_name: @item.item_name,
              description: @item.description,
              price: @item.price,
              iva: @item.iva
            }
          }
    assert_redirected_to items_url(locale: I18n.locale)
  end

  test "can't delete product in invoice" do
    assert_difference("Item.count", 0) { delete item_url(items(:second)) }
    assert_response :unprocessable_entity
  end

  test "should destroy item" do
    @item = items(:third)
    assert_difference("Item.count", -1) { delete item_url(@item) }

    assert_redirected_to items_url(locale: I18n.locale)
  end
end
