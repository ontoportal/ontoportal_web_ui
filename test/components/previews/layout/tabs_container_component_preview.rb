class Layout::TabsContainerComponentPreview < ViewComponent::Preview

  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def default
    render TabsContainerComponent.new do |c|
      sections = ['section 1', 'section 2', 'section 3', 'section 4']

      sections.each do |section_title|
        c.item(title: section_title,
               path: "#{section_title}path",
               selected: section_title.eql?('section 2'),
               page_name: "#{section_title}path")

        c.item_content do
          section_title
        end
      end

    end
  end

  def pill
    render TabsContainerComponent.new(pill: true) do |c|
      sections = ['section 1', 'section 2', 'section 3', 'section 4']

      sections.each do |section_title|
        c.item(title: section_title,
               path: "#{section_title}path",
               selected: section_title.eql?('section 2'),
               page_name: "#{section_title}path")

        c.item_content do
          section_title
        end
      end

    end
  end

end