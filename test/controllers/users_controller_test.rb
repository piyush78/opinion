require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "should get newuser" do
    get users_newuser_path
    assert_response :success
  end
end
