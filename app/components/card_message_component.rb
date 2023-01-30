class CardMessageComponent < ViewComponent::Base
    def initialize(title: ,message:, button_text:, type:)
        #if title == "no-title" then the component has no title
        #if button_text == "no-button" then the component has no button
        @title = title
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
