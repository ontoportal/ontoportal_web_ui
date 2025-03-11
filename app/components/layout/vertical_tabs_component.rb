# frozen_string_literal: true

class Layout::VerticalTabsComponent < ViewComponent::Base

  renders_many :item_contents

  def initialize(id: nil, titles: [], header: nil , selected: nil,  url_parameter: nil)
    @id = id
    @titles = titles
    @selected = selected
    @header = header
    @url_parameter =  url_parameter
  end

end
