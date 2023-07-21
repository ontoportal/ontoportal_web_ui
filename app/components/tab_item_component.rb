# frozen_string_literal: true

class TabItemComponent < ViewComponent::Base

  include ActionView::Helpers::UrlHelper

  def initialize(title:, path:, page_name: '', selected: false)
    super
    @title = title
    @path = path
    @page_name = page_name
    @selected = selected
  end

  def selected_item?
    @selected
  end

  def item_id
    @title.parameterize.underscore
  end

  def target_id
    "#{item_id}_content"
  end

  def target
    "##{target_id}"
  end

  def active_class
    selected_item? ? 'active show' : ''
  end

  def call
    link_to(@title.humanize, "#hello", id: "#{item_id}_tab")
  end

end
