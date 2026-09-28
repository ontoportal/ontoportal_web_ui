# app/lib/flipper_setup.rb
module FlipperSetup
  FEATURES = ["Agents", "SPARQL", "SIDEKIQ_UI", "FOOPS"].freeze
  DISABLED_BY_DEFAULT_FEATURES = ["biomixer_replacement"].freeze

  def self.configure!
    Flipper.configure do |config|
      config.default do
        primary_adapter = Flipper::Adapters::ActiveRecord.new

        flipper = Flipper.new(Flipper::Adapters::ActiveSupportCacheStore.new(
            primary_adapter,
            Rails.cache,
            10.minutes
          )
        )

        # Seed features enabled by default, without overriding those already
        # configured by an admin in the Flipper UI
        existing_features = primary_adapter.features
        FEATURES.each { |feature| flipper.enable(feature) unless existing_features.include?(feature) }
        DISABLED_BY_DEFAULT_FEATURES.each { |feature| flipper.add(feature) unless existing_features.include?(feature) }

        flipper
      end
      Flipper.register(:admins) do |actor, context|
        actor.respond_to?(:admin?) && actor.admin?
      end
    end
  end

  def self.test_configure!
    FEATURES.each { |feature| Flipper.enable(feature) }
    DISABLED_BY_DEFAULT_FEATURES.each { |feature| Flipper.add(feature) }
  end
end
