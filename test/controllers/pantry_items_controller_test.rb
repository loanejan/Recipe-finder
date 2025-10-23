require "test_helper"

class PantryItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pantry_items_index_url
    assert_response :success
  end

  test "should get create" do
    get pantry_items_create_url
    assert_response :success
  end

  test "should get destroy" do
    get pantry_items_destroy_url
    assert_response :success
  end
end
