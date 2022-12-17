# frozen_string_literal: true

module KGCL
  module IssueContentGenerator
    RENDERERS = {
      KGCL::Operations::NEW_SYNONYM => KGCL::Renderers::NewSynonymContent,
      KGCL::Operations::REMOVE_SYNONYM => KGCL::Renderers::RemoveSynonymContent
    }.freeze

    def self.call(params)
      operation = params[:operation]
      raise ArgumentError, "Invalid KGCL operation: #{operation}" unless RENDERERS.key?(operation)

      renderer = RENDERERS.fetch(operation)
      renderer.new(params).render
    end
  end
end
