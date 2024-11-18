module ComponentsHelper

  def tab_item_component(container_tabs:, title:, path:, selected: false, json_link: "", &content)
    container_tabs.item(title: title.html_safe, path: path, selected: selected, json_link: json_link)
    container_tabs.item_content { capture(&content) }
  end

  def alert_component(message, type: "info")
    render Display::AlertComponent.new(type: type, message: message)
  end

  def chips_component(id: , name: , label: , value: , checked: false , tooltip: nil, disabled: false, &block)
    content_tag(:div, data: { controller: 'tooltip' }, title: tooltip) do
      check_input(id: id, name: name, value: value, label: label, checked: checked, disabled: disabled, &block)
    end
  end


  def paginated_list_component(id:, results:, next_page_url:, child_url:, child_turbo_frame:, child_param:, open_in_modal: false , selected: nil, auto_click: false, submission: nil)
    render(TreeInfiniteScrollComponent.new(
      id:  id,
      collection: results.collection,
      next_url: next_page_url,
      current_page: results.page,
      next_page: results.nextPage,
      auto_click: auto_click,
      )) do |c|
      if results.page.eql?(1)
        concat(content_tag(:div, class: 'ontologies-selector-results') do
          content_tag(:div, class: 'results-number small ml-2') do
            "#{t('ontologies.showing')} #{results.totalCount}".html_safe
          end
        end)
      end

      concepts = c.collection
      if concepts && !concepts.empty?
        concepts.each do |concept|
          concept.id = concept["@id"] unless concept.id
          data = {  child_param => concept.id }
          href = child_url.include?('?') ? "#{child_url}&id=#{escape(concept.id)}" : "#{child_url}?id=#{escape(concept.id)}"
          concat(render(TreeLinkComponent.new(
            child: concept,
            href: href,
            children_href: '#',
            selected: selected.blank? ? false : concept.id.eql?(selected) ,
            target_frame: child_turbo_frame,
            data: data,
            open_in_modal: open_in_modal,
            is_reused: concept_reused?(submission: submission, concept_id: concept.id)
          )))
        end
      end
      c.error do
        t('components.tree_view_empty')
      end
    end
  end


  def rounded_button_component(link)
    render RoundedButtonComponent.new(link: link, target: '_blank',size: 'small',title: t("components.go_to_api"))
  end

  def copy_link_to_clipboard(url, show_content: false)
    content_tag(:span, style: 'display: inline-block;') do
      render ClipboardComponent.new(title: t("components.copy_original_uri"), message: url, show_content: show_content)
    end
  end

  def generated_link_to_clipboard(url, acronym)
    url = "#{$UI_URL}/ontologies/#{acronym}/#{link_last_part(url)}"
    content_tag(:span, id: "generate_portal_link", style: 'display: inline-block;') do
      render ClipboardComponent.new(icon: 'icons/copy_link.svg', title: "#{t("components.copy_portal_uri", portal_name: portal_name)} #{link_to(url)}", message: url, show_content: false)
    end
  end

  def tree_component(root, selected, target_frame:, sub_tree: false, id: nil, auto_click: false, submission: nil, &child_data_generator)
    root.children.sort! { |a, b| (a.prefLabel || a.id).downcase <=> (b.prefLabel || b.id).downcase }

    render TreeViewComponent.new(id: id, sub_tree: sub_tree, auto_click: auto_click) do |tree_child|
      root.children.each do |child|
        children_link, data, href = child_data_generator.call(child)

        if children_link.nil? || data.nil? || href.nil?
          raise ArgumentError, t('components.error_block')
        end

        tree_child.child(child: child, href: href,
                         children_href: children_link, selected: child.id.eql?(selected&.id),
                         muted: child.isInActiveScheme&.empty?,
                         target_frame: target_frame,
                         data: data, is_reused: concept_reused?(submission: submission, concept_id: child.id)) do
          tree_component(child, selected, target_frame: target_frame, sub_tree: true,
                         id: id, auto_click: auto_click, submission: submission, &child_data_generator)
        end
      end
    end
  end

  def chart_component(title: '', type:, labels:, datasets:, index_axis: 'x', show_legend: false)
    data = {
      controller: 'load-chart',
      'load-chart-type-value': type,
      'load-chart-title-value': title,
      'load-chart-labels-value': labels,
      'load-chart-index-axis-value': index_axis,
      'load-chart-datasets-value': datasets,
      'load-chart-legend-value': show_legend,
    }
    content_tag(:canvas, nil, data: data)
  end

  def loader_component(type:'pulsing', small: false )
    render LoaderComponent.new(type: type, small: small)
  end

  def info_tooltip(text, interactive: true)
    render Display::InfoTooltipComponent.new(text: text, interactive: interactive)
  end

  def empty_state_message(message)
    content_tag(:p, message.html_safe, class: 'font-italic field-description_text')
  end

  def properties_list_component(c, properties, truncate: true, &block)
    properties.each do |k, value|
      values, label = value
      c.row do
        content = if block_given?
                    capture(values, &block)
                  else
                    if Array(values).any?{|v| link?(v)}
                      horizontal_list_container(values, truncate: truncate) { |v| link?(v) ? render(LinkFieldComponent.new(value: v)) : v }
                    else
                      Array(values).join(', ')
                    end
                  end
        render FieldContainerComponent.new(label: attr_label(k, label, attr_metadata: attr_metadata(k.to_s), show_tooltip: false), value: content.to_s.html_safe)
      end
    end

  end


  def regular_button(id, value, variant: "secondary", state: "regular", size: "slim", &block)
    render Buttons::RegularButtonComponent.new(id:id, value: value, variant: variant, state: state, size: size) do |btn|
      capture(btn, &block) if block_given?
    end
  end

end
