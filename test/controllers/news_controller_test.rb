require 'test_helper'
require 'minitest/mock'

class NewsControllerTest < ActionController::TestCase
  tests NewsController

  setup do
    @entry = NewsEntry.new(id: 1, title: 'A story', slug: 'a-story', body_html: '<p>Story</p>', status: 'published', published_at: Time.current)
  end

  test 'disabled feature returns 404 before loading entries' do
    NewsEntry.stub(:published, -> { flunk 'NewsEntry should not be queried' }) do
      Flipper.stub(:enabled?, false) { get :index }
    end
    assert_response :not_found
  end

  test 'enabled feature renders a bounded set of published entries' do
    published = Minitest::Mock.new
    published.expect(:limit, [@entry], [NewsController::PUBLIC_ENTRY_LIMIT])
    NewsEntry.stub(:published, published) do
      Flipper.stub(:enabled?, ->(feature, _actor = nil) { feature.to_sym == :news_cms }) do
        get :index
      end
    end
    published.verify
    assert_response :success
    assert_includes response.body, 'A story'
  end

  test 'show only finds published entries' do
    entry = NewsEntry.create!(title: @entry.title, body_html: @entry.body_html, status: @entry.status, published_at: @entry.published_at)
    Flipper.stub(:enabled?, ->(feature, _actor = nil) { feature.to_sym == :news_cms }) do
      get :show, params: { slug: entry.slug }
    end
    assert_response :success
  end
end
