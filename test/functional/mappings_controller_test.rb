require File.dirname(__FILE__) + '/../test_helper'
require 'mappings_controller'

# Re-raise errors caught by the controller.
class MappingsController; def rescue_action(e) raise e end; end

class MappingsControllerTest < Test::Unit::TestCase
  fixtures :mappings

  def setup
    @controller = MappingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:mappings)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_mapping
    old_count = Mapping.count
    post :create, :mapping => { }
    assert_equal old_count+1, Mapping.count
    
    assert_redirected_to mapping_path(assigns(:mapping))
  end

  def test_should_show_mapping
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_mapping
    put :update, :id => 1, :mapping => { }
    assert_redirected_to mapping_path(assigns(:mapping))
  end
  
  def test_should_destroy_mapping
    old_count = Mapping.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Mapping.count
    
    assert_redirected_to mappings_path
  end
end
