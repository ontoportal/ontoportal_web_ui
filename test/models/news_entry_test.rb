require 'test_helper'

class NewsEntryTest < ActiveSupport::TestCase
  test 'sanitizes body HTML and generates a safe slug' do
    entry = NewsEntry.new(title: 'A New Story!', body_html: '<p>Hello</p><script>alert(1)</script>', status: 'draft')
    assert entry.valid?
    assert_equal 'a-new-story', entry.slug
    assert_equal '<p>Hello</p>alert(1)', entry.body_html
  end

  test 'published scope excludes drafts, future entries, and expired entries' do
    now = Time.current
    visible = NewsEntry.create!(title: 'Visible', body_html: 'Visible', status: 'published', published_at: now - 1.hour)
    NewsEntry.create!(title: 'Draft', body_html: 'Draft', status: 'draft')
    NewsEntry.create!(title: 'Future', body_html: 'Future', status: 'published', published_at: now + 1.hour)
    NewsEntry.create!(title: 'Expired', body_html: 'Expired', status: 'published', published_at: now - 2.hours, expires_at: now - 1.hour)

    assert_equal [visible], NewsEntry.published.to_a
  end

  test 'pinned entries sort before other published entries' do
    regular = NewsEntry.create!(title: 'Regular', body_html: 'Regular', status: 'published', published_at: 2.hours.ago)
    pinned = NewsEntry.create!(title: 'Pinned', body_html: 'Pinned', status: 'published', published_at: 1.hour.ago, pinned: true)

    assert_equal [pinned, regular], NewsEntry.published.to_a
  end
end
