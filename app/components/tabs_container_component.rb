# frozen_string_literal: true

class TabsContainerComponent < ViewComponent::Base

  renders_many :items, TabItemComponent
  renders_many :item_contents

  def initialize(url_parameter: nil)
    super
    @url_parameter = url_parameter
  end

  def tabs_container_data(item)
    {
      toggle: 'tab',
      target: item.target,
      'tab-id': item.id,
      'tab-title': item.title,
      'url-parameter': @url_parameter,
      action: 'click->tabs-container#selectTab'
    }
  end

end
