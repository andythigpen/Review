require 'test_helper'

class DiffsControllerTest < ActionController::TestCase
  setup do
    @diff = diffs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:diffs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create diff" do
    assert_difference('Diff.count') do
      post :create, :diff => @diff.attributes
    end

    assert_redirected_to diff_path(assigns(:diff))
  end

  test "should show diff" do
    get :show, :id => @diff.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @diff.to_param
    assert_response :success
  end

  test "should update diff" do
    put :update, :id => @diff.to_param, :diff => @diff.attributes
    assert_redirected_to diff_path(assigns(:diff))
  end

  test "should destroy diff" do
    assert_difference('Diff.count', -1) do
      delete :destroy, :id => @diff.to_param
    end

    assert_redirected_to diffs_path
  end
end
