# frozen_string_literal: true
class Buttons::PrimaryButtonComponentPreview < ViewComponent::Preview
  def default
    
    

    def default()
      render Buttons::PrimaryButtonComponent.new(value: "Login", name: "login", type: "regular")
    end
  end
end