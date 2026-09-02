require 'test_helper'
require 'minitest/mock'

class NewsFeedsControllerTest < ActionController::TestCase
  tests NewsController

  test 'disabled RSS and Atom requests return 404 without loading entries' do
    NewsEntry.stub(:published, -> { flunk 'NewsEntry should not be queried' }) do
      Flipper.stub(:enabled?, false) do
        get :index, params: { format: :rss }
        assert_response :not_found
        get :index, params: { format: :atom }
        assert_response :not_found
      end
    end
  end

  test 'enabled RSS and Atom feeds expose stable entry fields' do
    entry = NewsEntry.create!(title: 'Feed story', body_html: '<p>Feed body</p>', status: 'published', published_at: Time.current)
    Flipper.stub(:enabled?, ->(feature, _actor = nil) { feature.to_sym == :news_cms }) do
      get :index, params: { format: :rss }
      assert_response :success
      assert_includes response.body, 'Feed story'
      assert_includes response.body, news_path(entry.slug)

      get :index, params: { format: :atom }
      assert_response :success
      assert_includes response.body, 'Feed story'
      assert_includes response.body, news_path(entry.slug)
    end
  end
end
