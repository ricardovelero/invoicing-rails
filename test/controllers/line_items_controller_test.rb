require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup { @line_item = line_items(:one) }

  test "should get index" do
    get line_items_url
    assert_response :success
  end

  test "should get new" do
    get new_line_item_url
    assert_response :success
  end

  test "should create line_item" do
    assert_difference("LineItem.count") do
      post line_items_url,
           params: {
             line_item: {
               invoice_id: @line_item.invoice_id,
               item_id: @line_item.item_id
             }
           }
    end

    assert_redirected_to line_item_url(LineItem.last)
  end

  test "should show line_item" do
    get line_item_url(@line_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item),
          params: {
            line_item: {
              invoice_id: @line_item.invoice_id,
              item_id: @line_item.item_id
            }
          }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) { delete line_item_url(@line_item) }

    assert_redirected_to line_items_url
  end
end
