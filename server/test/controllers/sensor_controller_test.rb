require 'test_helper'


class SensorControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end
end
