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

  def top_tab(title, link, controllers = [])
    controllers = controllers.kind_of?(Array) ? controllers : [controllers]
    controllers.map! {|c| c.downcase}
    active = controllers.include?(controller.controller_name)
    active_class = active ? "nav_text_active" : ""
    content_tag(:li, content_tag(:a, title, :href => link, :title => title), :class => "nav_text #{active_class}")
  end


end
