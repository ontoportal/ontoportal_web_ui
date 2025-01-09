module ComponentsHelper

  def tab_item_component(container_tabs:, title:, path:, selected: false, json_link: "", &content)
    container_tabs.item(title: title.html_safe, path: path, selected: selected, json_link: json_link)
    container_tabs.item_content { capture(&content) }
  end

  def alert_component(message, type: "info")
    render Display::AlertComponent.new(type: type, message: message)
  end

  def list_items_component(max_items:, &block)
    render ListItemsShowMoreComponent.new(max_items: max_items) do |r|
      capture(r, &block)
    end
  end

  def link_to_with_actions(link_to_tag, acronym: nil, url: nil, copy: true, check_resolvability: true, generate_link: true, generate_htaccess: false)
    tag = link_to_tag
    url = link_to_tag if url.nil?

    tag += content_tag(:span, class: 'mx-1') do
      concat copy_link_to_clipboard(url) if copy
    end

    tag.html_safe
  end

  def rounded_button_component(link)
    render RoundedButtonComponent.new(link: link, target: '_blank', size: 'small', title: t("components.go_to_api"))
  end

  def copy_link_to_clipboard(url, show_content: false)
    content_tag(:span, style: 'display: inline-block;') do
      render ClipboardComponent.new(title: t("components.copy_original_uri"), message: url, show_content: show_content)
    end
  end

  def loader_component(type: 'pulsing', small: false)
    render LoaderComponent.new(type: type, small: small)
  end

  def info_tooltip(text, interactive: true)
    render Display::InfoTooltipComponent.new(text: text, interactive: interactive)
  end

  def empty_state_message(message)
    content_tag(:p, message.html_safe, class: 'font-italic field-description_text')
  end

  def regular_button(id, value, variant: "secondary", state: "regular", size: "slim", &block)
    render Buttons::RegularButtonComponent.new(id: id, value: value, variant: variant, state: state, size: size) do |btn|
      capture(btn, &block) if block_given?
    end
  end

end
