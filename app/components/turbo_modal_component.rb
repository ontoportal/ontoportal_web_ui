# frozen_string_literal: true

class TurboModalComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(id: '', title:'')
    super
    @id = id
    @title = title
  end

end
