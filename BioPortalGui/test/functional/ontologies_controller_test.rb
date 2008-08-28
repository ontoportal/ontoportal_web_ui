require File.dirname(__FILE__) + '/../test_helper'
require 'ontologies_controller'

# Re-raise errors caught by the controller.
class OntologiesController; def rescue_action(e) raise e end; end

class OntologiesControllerTest < Test::Unit::TestCase
  fixtures :ontologies

  def setup
    @controller = OntologiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:ontologies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_ontology
    old_count = Ontology.count
    post :create, :ontology => { }
    assert_equal old_count+1, Ontology.count
    
    assert_redirected_to ontology_path(assigns(:ontology))
  end

  def test_should_show_ontology
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_ontology
    put :update, :id => 1, :ontology => { }
    assert_redirected_to ontology_path(assigns(:ontology))
  end
  
  def test_should_destroy_ontology
    old_count = Ontology.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Ontology.count
    
    assert_redirected_to ontologies_path
  end
end
