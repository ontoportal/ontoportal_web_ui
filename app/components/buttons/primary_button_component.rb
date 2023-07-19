class Buttons::PrimaryButtonComponent < ViewComponent::Base
    def initialize(name: "", value: , type: "regular", style: "regular", color: "primary", onclick: "")
        @name = name
        @value = value
        @type = type
        @style = style
        @color = color
        @onclick = onclick
    end
end
