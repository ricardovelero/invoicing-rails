require "test_helper"

class ChartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:first)
  end

  test "should get show" do
    get chart_url(chart_type: "Charts::InvoicesChart")
    assert_response :success
  end
end
