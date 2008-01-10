require File.dirname(__FILE__) + '/../test_helper'
require 'margin_notes_controller'

# Re-raise errors caught by the controller.
class MarginNotesController; def rescue_action(e) raise e end; end

class MarginNotesControllerTest < Test::Unit::TestCase
  fixtures :margin_notes

  def setup
    @controller = MarginNotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:margin_notes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_margin_note
    old_count = MarginNote.count
    post :create, :margin_note => { }
    assert_equal old_count+1, MarginNote.count
    
    assert_redirected_to margin_note_path(assigns(:margin_note))
  end

  def test_should_show_margin_note
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_margin_note
    put :update, :id => 1, :margin_note => { }
    assert_redirected_to margin_note_path(assigns(:margin_note))
  end
  
  def test_should_destroy_margin_note
    old_count = MarginNote.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MarginNote.count
    
    assert_redirected_to margin_notes_path
  end
end
