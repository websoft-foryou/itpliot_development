require 'test_helper'

class ServiceDependancesControllerTest < ActionController::TestCase
  setup do
    @service_dependance = service_dependances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_dependances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_dependance" do
    assert_difference('ServiceDependance.count') do
      post :create, service_dependance: { depending_id: @service_dependance.depending_id, service_id: @service_dependance.service_id }
    end

    assert_redirected_to service_dependance_path(assigns(:service_dependance))
  end

  test "should show service_dependance" do
    get :show, id: @service_dependance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_dependance
    assert_response :success
  end

  test "should update service_dependance" do
    put :update, id: @service_dependance, service_dependance: { depending_id: @service_dependance.depending_id, service_id: @service_dependance.service_id }
    assert_redirected_to service_dependance_path(assigns(:service_dependance))
  end

  test "should destroy service_dependance" do
    assert_difference('ServiceDependance.count', -1) do
      delete :destroy, id: @service_dependance
    end

    assert_redirected_to service_dependances_path
  end
end
