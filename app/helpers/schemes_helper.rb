module SchemesHelper


  def concept_label_to_show(submission: @submission_latest)
    submission.hasOntologyLanguage == 'SKOS' ? 'Concepts' : 'Classes'
  end

  def section_name(section)
    if section.eql?('classes')
      concept_label_to_show(submission: @submission_latest || @submission)
    else
      section.capitalize
    end
  end
end

