# frozen_string_literal: true

module SubmissionsHelper

  def metadata_help_link
    content_tag(:div, class: 'edit-ontology-desc') do
      html = content_tag(:div) do
        content_tag(:div, t('submission_inputs.edit_metadata_instruction',
                            portal_name: portal_name,
                            link: link_to(t('submission_inputs.edit_metadata_instruction_link'), Rails.configuration.settings.links[:metadata_help], target: '_blank')).html_safe
        )
      end

      html.html_safe
    end
  end

  def acronym_from_submission_muted(submission)
    acronym =
      if submission.ontology.respond_to? :acronym
        submission.ontology.acronym
      else
        submission.ontology.split('/')[-1]
      end
    tag.small "for #{acronym}", class: 'text-muted'
  end

  def acronym_from_params_muted
    tag.small "for #{params[:ontology_id]}", class: 'text-muted'
  end

  def natural_language_selector(submission)
    language_codes = ISO_639::ISO_639_1.map do |code|
      #  Get the alpha-2 code and English name
      code.slice(2, 2).reverse
    end
    language_codes.sort! { |a, b| a.first.downcase <=> b.first.downcase }

    selected = submission.naturalLanguage
    select(:submission, :naturalLanguage, options_for_select(language_codes, selected),
           { include_blank: true },
           { multiple: true, class: 'form-select', 'aria-describedby': 'languageHelpBlock' })
  end
end
