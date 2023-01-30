class CardMessageComponent < ViewComponent::Base
    def initialize(message:, button_text:, type:)
        @message = message
        @button_text = button_text
        @type = type
        case type
        when "success"
            @icon = "green-check.svg"
        when "failure"
            @icon = "red-warning.svg"
        end
    end
end
