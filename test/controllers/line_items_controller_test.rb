require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
    @invoice = @line_item.invoice
    sign_in users(:first)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) { delete invoice_line_item_url(@invoice, @line_item) }

    assert_redirected_to invoice_url(@invoice, locale: I18n.locale)
  end
end
