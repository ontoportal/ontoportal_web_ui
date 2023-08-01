# frozen_string_literal: true
class Buttons::RegularButtonComponentPreview < ViewComponent::Preview
  layout 'component_preview_not_centred'


  def primary
    def primary()
      render Buttons::RegularButtonComponent.new(value: "Login", name: "login", type: "link", variant: "primary", href: "https://www.google.com")
    end
  end

  
  def secondary
    def secondary()
      render Buttons::RegularButtonComponent.new(value: "Login", name: "login", type: "link", variant: "secondary",href: "https://www.google.com")
    end
  end


end