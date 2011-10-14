require 'hpricot'
require 'open-uri'

module HomeHelper

  def get_help_page_from_wiki
    return nil if $WIKI_HELP_PAGE.nil? || $WIKI_HELP_PAGE.length == 0

    help_text = CACHE.get("help_text")
    if help_text.nil?
      help_page = Hpricot(open($WIKI_HELP_PAGE))
      help_text = (help_page/"//*[@id='bodyContent']").inner_html
      CACHE.set("help_text", help_text, 60*60)
    end

    return help_text
  end

end
