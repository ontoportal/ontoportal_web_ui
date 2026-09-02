xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'News'
    xml.link news_index_url
    xml.description "#{portal_name} news"
    @news_entries.each do |entry|
      url = news_url(entry.slug)
      xml.item do
        xml.title entry.title
        xml.link url
        xml.guid url
        xml.pubDate (entry.published_at || entry.created_at).rfc2822
        xml.description { xml.cdata!(entry.excerpt) }
      end
    end
  end
end
