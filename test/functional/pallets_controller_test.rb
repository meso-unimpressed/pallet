require File.dirname(__FILE__) + '/../test_helper'

class PalletsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pallets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pallet
    assert_difference('Pallet.count') do
      post :create, :pallet => { }
    end

    assert_redirected_to pallet_path(assigns(:pallet))
  end

  def test_should_show_pallet
    get :show, :id => pallets(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => pallets(:one).id
    assert_response :success
  end

  def test_should_update_pallet
    put :update, :id => pallets(:one).id, :pallet => { }
    assert_redirected_to pallet_path(assigns(:pallet))
  end

  def test_should_destroy_pallet
    assert_difference('Pallet.count', -1) do
      delete :destroy, :id => pallets(:one).id
    end

    assert_redirected_to pallets_path
  end
end
