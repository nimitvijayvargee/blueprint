require "test_helper"

class ShopItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get shop_items_new_url
    assert_response :success
  end

  test "should get create" do
    get shop_items_create_url
    assert_response :success
  end
end
