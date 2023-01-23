class PopupMessageComponent < ViewComponent::Base
    def initialize(message:, button_text:, icon:)
        @message = message
        @button_text = button_text
        @icon = icon
    end
end