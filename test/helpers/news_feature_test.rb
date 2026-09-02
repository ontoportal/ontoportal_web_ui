require 'test_helper'

class NewsFeatureTest < ActionView::TestCase
  include ApplicationHelper

  test 'news flag is off by default in the feature registry' do
    assert_not Flipper.enabled?(:news_cms)
  end
end
