require 'test_helper'

class ReviewEventsControllerTest < ActionController::TestCase
  setup do
    @review_event = review_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:review_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review_event" do
    assert_difference('ReviewEvent.count') do
      post :create, :review_event => @review_event.attributes
    end

    assert_redirected_to review_event_path(assigns(:review_event))
  end

  test "should show review_event" do
    get :show, :id => @review_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @review_event.to_param
    assert_response :success
  end

  test "should update review_event" do
    put :update, :id => @review_event.to_param, :review_event => @review_event.attributes
    assert_redirected_to review_event_path(assigns(:review_event))
  end

  test "should destroy review_event" do
    assert_difference('ReviewEvent.count', -1) do
      delete :destroy, :id => @review_event.to_param
    end

    assert_redirected_to review_events_path
  end
end
