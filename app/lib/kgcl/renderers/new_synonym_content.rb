# frozen_string_literal: true

class NewSynonymContent
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def acronym
    @params[:acronym]
  end

  def render
    b = binding
    title = ERB.new('Add synonym: <%= pref_label %>', trim_mode: '%<>').result b
    template = File.read("#{Rails.root}/app/lib/kgcl/templates/new_synonym_body.erb")
    body = ERB.new(template, trim_mode: '<>').result b
    { title: title, body: body }
  end

  def dbxrefs
    @params[:dbxrefs]
  end

  def orcid
    @params[:orcid]
  end

  def path_info
    @params[:path_info]
  end

  def pref_label
    @params[:pref_label]
  end

  def synonym
    @params[:synonym]
  end

  def subtypes
    @params[:subtypes]
  end

  def username
    @params[:username]
  end
end
