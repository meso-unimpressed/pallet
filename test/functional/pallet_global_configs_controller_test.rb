require File.dirname(__FILE__) + '/../test_helper'

class PalletGlobalConfigsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pallet_global_configs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pallet_global_config
    assert_difference('PalletGlobalConfig.count') do
      post :create, :pallet_global_config => { }
    end

    assert_redirected_to pallet_global_config_path(assigns(:pallet_global_config))
  end

  def test_should_show_pallet_global_config
    get :show, :id => pallet_global_configs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => pallet_global_configs(:one).id
    assert_response :success
  end

  def test_should_update_pallet_global_config
    put :update, :id => pallet_global_configs(:one).id, :pallet_global_config => { }
    assert_redirected_to pallet_global_config_path(assigns(:pallet_global_config))
  end

  def test_should_destroy_pallet_global_config
    assert_difference('PalletGlobalConfig.count', -1) do
      delete :destroy, :id => pallet_global_configs(:one).id
    end

    assert_redirected_to pallet_global_configs_path
  end
end
