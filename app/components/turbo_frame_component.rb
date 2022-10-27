# frozen_string_literal: true

class TurboFrameComponent < ViewComponent::Base
  include Turbo::FramesHelper
  def initialize(id:, src: '')
    @id = id
    @src = src
  end
end
