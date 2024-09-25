require "test_helper"

class TopicCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get topic_categories_index_url
    assert_response :success
  end

  test "should get edit" do
    get topic_categories_edit_url
    assert_response :success
  end
end
