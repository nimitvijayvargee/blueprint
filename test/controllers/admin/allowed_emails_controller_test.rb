require "test_helper"

class Admin::AllowedEmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_allowed_emails_index_url
    assert_response :success
  end

  test "should get create" do
    get admin_allowed_emails_create_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_allowed_emails_destroy_url
    assert_response :success
  end
end
