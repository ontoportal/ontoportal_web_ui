class Buttons::SecondaryButtonComponentPreview < ViewComponent::Preview
  layout 'component_preview_not_centred'
  def default
    def default()
      render Buttons::SecondaryButtonComponent.new(value: "Login", name: "login", type: "regular")
    end
  end
end