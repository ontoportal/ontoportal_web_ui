require 'test_helper'
require 'minitest/mock'

class AdminNewsEntriesControllerTest < ActionController::TestCase
  tests Admin::NewsEntriesController

  setup do
    @request.session[:user] = Struct.new(:id, :username, :admin?).new('1', 'editor', true)
  end

  test 'disabled feature returns 404 before authorization or loading entries' do
    NewsEntry.stub(:order, ->(*) { flunk 'NewsEntry should not be queried' }) do
      Flipper.stub(:enabled?, false) { get :index }
    end
    assert_response :not_found
  end

  test 'admin can create an entry with author attribution' do
    Flipper.stub(:enabled?, ->(feature, _actor = nil) { feature.to_sym == :news_cms }) do
      assert_difference 'NewsEntry.count', 1 do
        post :create, params: { news_entry: { title: 'New story', body_html: '<p>Body</p>', status: 'draft' } }
      end
    end
    assert_redirected_to admin_news_entries_path
    assert_equal 'editor', NewsEntry.order(:id).last.author_name
  end
end
