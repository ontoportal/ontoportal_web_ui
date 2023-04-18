class ChipsComponentPreview < ViewComponent::Preview
    def default
        render(ChipsComponent.new(name:"bug", value: "Bug"))
    end
  
  end