require "test_helper"

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:draft)
    @invoice = @line_item.invoice
    sign_in users(:first)
  end

  test "should destroy line_item" do
    assert_difference("LineItem.count", -1) { delete invoice_line_item_url(@invoice, @line_item) }

    assert_redirected_to invoice_url(@invoice, locale: I18n.locale)
  end

  test "should not destroy line_item of an issued invoice" do
    issued_line_item = line_items(:one)

    assert_no_difference("LineItem.count") do
      delete invoice_line_item_url(issued_line_item.invoice, issued_line_item)
    end
  end
end
