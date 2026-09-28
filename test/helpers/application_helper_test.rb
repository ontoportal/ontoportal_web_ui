require 'test_helper'
require 'flipper/adapters/memory'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  setup do
    @original_rest_url = LinkedData::Client.settings.rest_url rescue nil
    @original_fairness_url = $FAIRNESS_URL rescue nil
    @original_visualizer_url = $ONTOPANEL_VISUALIZER_URL rescue nil
    @original_visualizer_env = ENV['ONTOPANEL_VISUALIZER_URL']
  end

  teardown do
    LinkedData::Client.settings.rest_url = @original_rest_url if @original_rest_url
    $FAIRNESS_URL = @original_fairness_url
    $ONTOPANEL_VISUALIZER_URL = @original_visualizer_url
    ENV['ONTOPANEL_VISUALIZER_URL'] = @original_visualizer_env
  end

  test '#biomixer_replacement_enabled? follows the feature state' do
    with_memory_flipper do |flipper|
      refute biomixer_replacement_enabled?

      flipper.enable('biomixer_replacement')
      assert biomixer_replacement_enabled?

      flipper.disable('biomixer_replacement')
      refute biomixer_replacement_enabled?
    end
  end

  test '#biomixer_replacement_enabled? forwards the supplied actor' do
    with_memory_flipper do |flipper|
      user = Struct.new(:flipper_id).new('User;42')
      flipper.enable_actor('biomixer_replacement', user)

      assert biomixer_replacement_enabled?(user)
      refute biomixer_replacement_enabled?
    end
  end

  test '#ontopanel_visualizer_url uses the configured URL' do
    $ONTOPANEL_VISUALIZER_URL = 'https://visualizer.example.test/'

    assert_equal 'https://visualizer.example.test/', ontopanel_visualizer_url
  end

  test '#ontopanel_visualizer_url falls back to the bundled visualizer' do
    $ONTOPANEL_VISUALIZER_URL = nil
    ENV.delete('ONTOPANEL_VISUALIZER_URL')

    assert_equal '/biomixer-visualizer', ontopanel_visualizer_url
  end

  private

  def with_memory_flipper
    original_flipper = Flipper.instance
    memory_flipper = Flipper.new(Flipper::Adapters::Memory.new)
    Flipper.instance = memory_flipper
    yield memory_flipper
  ensure
    Flipper.instance = original_flipper
  end
end
