# frozen_string_literal: true

class RemoveSynonymContent
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def render
    b = binding

    template = File.read("#{Rails.root}/app/lib/kgcl/templates/remove_synonym_title.erb")
    title = ERB.new(template, trim_mode: '%<>').result b

    template = File.read("#{Rails.root}/app/lib/kgcl/templates/remove_synonym_body.erb")
    body = ERB.new(template, trim_mode: '<>').result b

    { title: title, body: body }
  end

  def comment
    @params[:comment]
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

  def username
    @params[:username]
  end
end
