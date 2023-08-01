# frozen_string_literal: true
class Buttons::RegularButtonComponentPreview < ViewComponent::Preview
  layout 'component_preview_not_centred'


  def primary
    def primary()
      render Buttons::RegularButtonComponent.new(value: "Login", name: "login", type: "submit", variant: "primary")
    end
  end

  
  def secondary
    def secondary()
      render Buttons::RegularButtonComponent.new(value: "Login", name: "login", type: "submit", variant: "secondary")
    end
  end


end