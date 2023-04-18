class CardMessageComponentPreview < ViewComponent::Preview
    def default
        render(CardMessageComponent.new(message: "A password reset email has been sent to your email, please follow the instructions in the email to reset your password.", button_text: "Back home", type:"success"))
    end
  
  end