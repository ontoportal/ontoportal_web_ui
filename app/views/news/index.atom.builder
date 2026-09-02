xml.instruct! :xml, version: '1.0'
xml.feed xmlns: 'http://www.w3.org/2005/Atom' do
  xml.title 'News'
  xml.link href: news_index_url
  xml.id news_index_url
  xml.updated((@news_entries.first&.published_at || @news_entries.first&.created_at || Time.current).iso8601)
  @news_entries.each do |entry|
    url = news_url(entry.slug)
    xml.entry do
      xml.title entry.title
      xml.link href: url
      xml.id url
      xml.updated((entry.published_at || entry.created_at).iso8601)
      xml.author { xml.name entry.author_name.presence || portal_name }
      xml.content entry.body_html, type: 'html'
    end
  end
end
