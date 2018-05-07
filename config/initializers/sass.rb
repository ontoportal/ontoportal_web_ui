module Sass::Script::Functions

  def body_margin_bottom
    margin = Rails.env.appliance? ? "60px" : "300px"
    Sass::Script::String.new(margin)
  end

  declare :body_margin_bottom, []

end