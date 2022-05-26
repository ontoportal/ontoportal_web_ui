# frozen_string_literal: true

require_relative '../template_renderer'

class NewSynonymContent
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def acronym
    @params[:acronym]
  end

  def render
    tr = TemplateRenderer.new(
      title_template: 'new_synonym_title.erb',
      body_template: 'new_synonym_body.erb',
      bind_klass: self
    )
    tr.render
  end

  def comment
    @params[:comment]
  end

  def curie
    @params[:curie]
  end

  def get_binding
    binding
  end

  def pref_label
    @params[:pref_label]
  end

  def synonym
    @params[:synonym]
  end

  def username
    @params[:username]
  end
end
