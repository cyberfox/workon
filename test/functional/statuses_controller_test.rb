require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  context "A logged in user" do
    setup do
      login_as :quentin
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:statuses)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create status" do
      assert_difference('Status.count') do
        post :create, :status => { }
      end

      assert_redirected_to status_path(assigns(:status))
    end

    should "show status" do
      get :show, :id => statuses(:quentin_first).to_param
      assert_response :success
    end

    should "get edit" do
      get :edit, :id => statuses(:quentin_first).to_param
      assert_response :success
    end

    should "update status" do
      put :update, :id => statuses(:quentin_first).to_param, :status => { }
      assert_redirected_to status_path(assigns(:status))
    end

    should "destroy status" do
      assert_difference('Status.count', -1) do
        delete :destroy, :id => statuses(:quentin_first).to_param
      end

      assert_redirected_to statuses_path
    end
  end
end
