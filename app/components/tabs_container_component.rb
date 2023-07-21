# frozen_string_literal: true

class TabsContainerComponent < ViewComponent::Base

  renders_many :items, TabItemComponent
  renders_many :item_contents

  def initialize
    super
  end

end
