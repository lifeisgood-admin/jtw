require "test_helper"

class PublicShowControllerTest < ActionDispatch::IntegrationTest
  test "should get general_top" do
    get public_show_general_top_url
    assert_response :success
  end
end
