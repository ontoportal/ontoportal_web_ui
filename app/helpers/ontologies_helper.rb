module OntologiesHelper

  def additional_details
    return "" if $ADDITIONAL_ONTOLOGY_DETAILS.nil? || $ADDITIONAL_ONTOLOGY_DETAILS[@ontology.acronym].nil?
    details = $ADDITIONAL_ONTOLOGY_DETAILS[@ontology.acronym]
    html = []
    details.each do |title, value|
      html << content_tag(:tr) do
        [content_tag(:th, title), content_tag(:td, value)].join("")
      end
    end
    html.join("")
  end

  def count_links(ont_acronym, page_name='summary', count=0)
    ont_url = "/ontologies/#{ont_acronym}"
    if count.nil? || count == 0
      return "0"
      #return "<a href='#{ont_url}/?p=summary'>0</a>"
    else
      return "<a href='#{ont_url}/?p=#{page_name}'>#{number_with_delimiter(count, :delimiter => ',')}</a>"
    end
  end

  def classes_link(ontology, count)
    return "0" if (ontology.summaryOnly || count.nil? || count == 0)
    return count_links(ontology.ontology.acronym, 'classes', count)
  end

  # Creates a link based on the status of an ontology submission
  def download_link(submission)
    if submission.ontology.summaryOnly
      if submission.homepage.nil?
        link = 'N/A'
      else
        uri = submission.homepage
        link = "<a href='#{uri}'>Home Page</a>"
      end
    else
      uri = submission.id + "/download?apikey=#{get_apikey}"
      link = "<a href='#{uri}' target='_blank'>Ontology</a>"
      unless submission.diffFilePath.nil?
        uri = submission.id + "/download_diff?apikey=#{get_apikey}"
        link = link + " | <a href='#{uri}' target='_blank'>Diff</a>"
      end
    end
    return link
  end

  def mappings_link(ontology, count)
    return "0" if (ontology.summaryOnly || count.nil? || count == 0)
    return count_links(ontology.ontology.acronym, 'mappings', count)
  end

  def notes_link(ontology, count)
    #count = 0 if ontology.summaryOnly
    return count_links(ontology.ontology.acronym, 'notes', count)
  end

  # Creates a link based on the status of an ontology submission
  def status_link(submission, latest=false)
    version_text = submission.version.nil? || submission.version.length == 0 ? "unknown" : submission.version
    status_text = " <span class='ontology_submission_status'>" + submission_status2string(submission) + "</span>"
    if submission.ontology.summaryOnly || latest==false
      version_link = version_text
    else
      version_link = "<a href='/ontologies/#{submission.ontology.acronym}?p=classes'>#{version_text}</a>"
    end
    return version_link + status_text
  end

  def submission_status2string(sub)
    # Massage the submission status into a UI string
    #submission status values, from:
    # https://github.com/ncbo/ontologies_linked_data/blob/master/lib/ontologies_linked_data/models/submission_status.rb
    # "UPLOADED", "RDF", "RDF_LABELS", "INDEXED", "METRICS", "ANNOTATOR", "ARCHIVED"  and 'ERROR_*' for each.
    # Strip the URI prefix from the status codes (works even if they are not URIs)
    # The order of the codes must be assumed to be random, it is not an entirely
    # predictable sequence of ontology processing stages.
    codes = sub.submissionStatus.map {|s| s.split('/').last }
    errors = codes.map {|c| c if c.start_with? 'ERROR'}.compact
    status = []
    status.push('Parsed') if (codes.include? 'RDF') && (codes.include? 'RDF_LABELS')
    if not errors.empty?
      status.concat errors
      # Forget about other status codes.
    else
      # The order of this array imposes an oder on the UI status code string
      status_list = [ "INDEXED", "METRICS", "ANNOTATOR", "ARCHIVED" ]
      status_list.insert(0, 'UPLOADED') unless status.include?('Parsed')
      status_list.each do |c|
        status.push(c.capitalize) if codes.include? c
      end
    end
    return '' if status.empty?
    return '(' + status.join(', ') + ')'
  end

  # Link for private/public/licensed ontologies
  def visibility_link(ontology)
    ont_url = "/ontologies/#{ontology.acronym}"  # 'ontology' is NOT a submission here
    page_name = 'summary'  # default ontology page view for visibility link
    link_name = 'Public'   # default ontology visibility
    if ontology.summaryOnly
      link_name = 'Summary Only'
    elsif ontology.private?
      link_name = 'Private'
    elsif ontology.licensed?
      link_name = 'Licensed'
    end
    return "<a href='#{ont_url}/?p=#{page_name}'>#{link_name}</a>"
  end


end
