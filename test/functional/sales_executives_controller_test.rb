require 'test_helper'
require 'declarative_authorization/maintenance'

class SalesExecutivesControllerTest < ActionController::TestCase
    include Devise::TestHelpers
    include Authorization::TestHelper

    setup do
        @sales_executive = sales_executives(:one)
        @user = users(:one)
        sign_in @user
    end

    test "should get index" do
        get :index
        assert_response :success
        assert_not_nil assigns(:sales_executives)
    end

    test "should get new" do
        get :new
        assert_response :success
    end

    test "should create sales_executive" do
        assert_difference('SalesExecutive.count') do
            post :create, sales_executive: { employee_id: @sales_executive.employee_id, team_leader_id: @sales_executive.team_leader_id, user_id: @sales_executive.user_id }
        end

        assert_redirected_to sales_executive_path(assigns(:sales_executive))
    end

    test "should show sales_executive" do
        get :show, id: @sales_executive
        assert_response :success
    end

    test "should get edit" do
        get :edit, id: @sales_executive
        assert_response :success
    end

    test "should update sales_executive" do
        put :update, id: @sales_executive, sales_executive: { employee_id: @sales_executive.employee_id, team_leader_id: @sales_executive.team_leader_id, user_id: @sales_executive.user_id }
        assert_redirected_to sales_executive_path(assigns(:sales_executive))
    end

    test "should destroy sales_executive" do
        assert_difference('SalesExecutive.count', -1) do
            delete :destroy, id: @sales_executive
        end

        assert_redirected_to sales_executives_path
    end
end
