module TurboHelper
  def frame_id(suffix)
    "#{controller_name}_#{suffix}"
  end

  def alerts_container_id
    frame_id('alerts_container')
  end

  def alert(type: 'success', &block)
    turbo_stream.prepend(alerts_container_id) do
      AlertMessageComponent.new(type: type).render_in(view_context, &block)
    end
  end
end