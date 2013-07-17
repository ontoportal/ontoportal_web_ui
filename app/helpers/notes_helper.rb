require 'cgi'

module NotesHelper

  NOTES_TAGS = %w(a br b em strong i)

  def recurse_replies(replies)
    return "" if replies.nil?
    html = ""
    replies.each do |reply|
      reply_html = <<-html
        <div class="reply">
          <div class="reply_author">
            <b>#{get_username(reply.creator)}</b> #{time_ago_in_words(DateTime.parse(@notes.created))} ago
          </div>
          <div class="reply_body">
            #{sanitize reply.body, tags: NOTES_TAGS}<br/>
          </div>
          <div class="reply_meta">
            <a href="#reply" class="reply_reply" data-parent_id="#{reply.id}">reply</a>
          </div>
          <div class="discussion">
            <div class="discussion_container">
              #{recurse_replies(reply.respond_to?(:children) ? reply.children : nil)}
            </div>
          </div>
        </div>
      html
      html << reply_html
    end
    html
  end

  def proposal_html(note)
    return "" unless note.respond_to?(:proposal) && note.proposal
    case note.proposal.type
    when "ProposalNewClass"
      html = <<-html
        <table class="proposal">
          <tr>
            <th>Reason for Change</th>
            <td>#{note.proposal.reasonForChange}</td>
          <tr>
            <th>Contact Info</th>
            <td>#{note.proposal.contactInfo}</td>
          </tr>
          <tr>
            <th>Preferred Name</th>
            <td>#{note.proposal.label}</td>
          <tr>
            <th>Provisional id</th>
            <td>#{note.proposal.classId}</td>
          <tr>
            <th>Parent</th>
            <td>#{note.proposal.parent}</td>
          </tr>
          <tr>
            <th>Synonyms</th>
            <td>#{note.proposal.synonym.join(", ")}</td>
          </tr>
          <tr>
            <th>Definition</th>
            <td>#{note.proposal.definition.join(", ")}</td>
          </tr>
        </table>
      html
    when "ProposalChangeHierarchy"
      html = <<-html
        <table class="proposal">
          <tr>
            <th>Relationship Type</th>
            <td>#{note.proposal.newRelationshipType.join(", ")}</td>
          </tr>
          <tr>
            <th>New Relationship Target</th>
            <td colspan="3">#{note.proposal.newTarget}</td>
          </tr>
          <tr>
            <th>Old Relationship Target</th>
            <td colspan="3">#{note.proposal.oldTarget}</td>
          </tr>
          <tr>
            <th>Reason for Change</th>
            <td>#{note.proposal.reasonForChange}</td>
          <tr>
            <th>Contact Info</th>
            <td>#{note.proposal.contactInfo}</td>
          </tr>
        </table>
      html
    when "ProposalChangeProperty"
      html = <<-html
        <table class="proposal">
          <tr>
            <th>Property id</th>
            <td>#{note.proposal.propertyId}</td>
          </tr>
          <tr>
            <th>New Property Value</th>
            <td colspan="3">#{note.proposal.newValue}</td>
          </tr>
          <tr>
            <th>Old Property Value</th>
            <td colspan="3">#{note.proposal.oldValue}</td>
          </tr>
          <tr>
            <th>Reason for Change</th>
            <td>#{note.proposal.reasonForChange}</td>
          <tr>
            <th>Contact Info</th>
            <td>#{note.proposal.contactInfo}</td>
          </tr>
        </table>
      html
    end

    html
  end

  def generate_reply_thread(replies)
    return "" if replies.empty?

    html = ""
    replies.each do |note|
      html1 = <<-html
        <div class="response_container">
          <div class="response" id="note_#{note["@id"]}">
            <div class="note_corner">&nbsp;</div>
            <div id="note_#{note["@id"]}_collapse" class="collapsible">
              <div class="response_body">
                #{sanitize note.body, tags: NOTES_TAGS}
              </div>
              <div class="create_reply_container" id="#{note["@id"]}_reply_link">
                <a class="create_reply" note_id="#{note["@id"]}" href="javascript:void(0)">reply</a>
              </div>
            </div>
      html

      html2 = note.respond_to?(:children) ? generate_reply_thread(note.children) : ""

      html3 = <<-html
            </div>
          </div>
        </div>
      html

      html << html1 + html2 + html3
    end

    html
  end

  def get_applies_to_link(ontology_id, type, id)
    # We don't use helper methods (like link_to or url_for) here because this can get called from the controller
    begin
      case type
      when "Class"
        return "<a href='/visualize/#{ontology_id}/?conceptid=#{CGI.escape(id)}#notes'>#{DataAccess.getNode(ontology_id, id).label_html}</a>"
      when "Note"
        ontology = DataAccess.getOntology(ontology_id)
        return "<a href='/notes/virtual/#{ontology.ontologyId}?noteid=#{id}'>#{DataAccess.getNote(ontology.ontologyId, id, false, true).subject}</a>"
      when "Individual"
      when "Property"
      when "Ontology"
        ontology = DataAccess.getOntology(ontology_id)
        return "<a href='/ontologies/#{ontology.ontologyId}/?p=notes'>#{ontology.displayLabel}</a>"
      end
    rescue Exception => e
      return "Unknown or Deprecated #{type}"
    end
  end

  def get_applies_to_url(ontology_id, type, id)
    # We don't use helper methods (like link_to or url_for) here because this can get called from the controller
    begin
      case type
      when "Class"
        return "/visualize/#{ontology_id}/?conceptid=#{CGI.escape(id)}#notes"
      when "Note"
        ontology = DataAccess.getOntology(ontology_id)
        return "/notes/virtual/#{ontology.ontologyId}?noteid=#{id}"
      when "Individual"
      when "Property"
      when "Ontology"
        ontology = DataAccess.getOntology(ontology_id)
        return "/ontologies/#{ontology.ontologyId}/?p=notes"
      end
    rescue
      return ""
    end
  end

  def get_note_type_text(note_type)
    case note_type
    when "Comment"
      return "Comment"
    when "ProposalNewClass"
      return "New Class Proposal"
    when "ProposalChangeHierarchy"
      return "New Relationship Proposal"
    when "ProposalChangeProperty"
      return "Change Property Value Proposal"
    end
  end

  def subscribe_button(ontology_id)
    user = session[:user]
    return "<a href='/login?redirect=#{request.request_uri}' style='font-size: .9em;' class='subscribe_to_notes'>Subscribe to notes emails</a>" if user.nil?

    # TODO_REV: Create subscription service?
    return "<a href='/login?redirect=#{request.request_uri}' style='font-size: .9em;' class='subscribe_to_notes'>Subscribe to notes emails</a>"
    subs = DataAccess.getUserSubscriptions(user.id)


    if !subs.nil?
      sub_text = subbed_to_ont?(ontology_id, subs) ? "Unsubscribe" : "Subscribe"
      params = "data-bp_ontology_id='#{ontology_id}' data-bp_is_subbed='#{subbed_to_ont?(ontology_id, subs)}' data-bp_user_id='#{user.id}'"
      spinner = '<span class="notes_subscribe_spinner" style="display: none;"><img src="/images/spinners/spinner_000000_16px.gif" style="vertical-align: text-bottom;"></span>'
      error = "<span style='color: red;' class='notes_sub_error'></span>"
      return "<a href='javascript:void(0);' class='subscribe_to_notes link_button' #{params}>#{sub_text} to notes emails</a> #{spinner} #{error}"
    else
      return ""
    end
  end

  def delete_button
    user = session[:user]
    # TODO_REV: Enable anonymous user
    # user ||= anonymous_user

    params = "data-bp_user_id='#{user.id}'"
    spinner = '<span class="delete_notes_spinner" style="display: none;"><img src="/images/spinners/spinner_000000_16px.gif" style="vertical-align: text-bottom;"></span>'
    error = "<span style='color: red;' class='delete_notes_error'></span>"
    return "<a href='#' onclick='deleteNotes(this);return false;' style='display: inline-block !important;' class='notes_delete link_button' #{params}>Delete selected notes</a> #{spinner} #{error}"
  end

  def subbed_to_ont?(ontology_id, subscriptions)
    subscriptions.each do |sub|
      return true if sub["ontologyId"].to_i == ontology_id.to_i
    end
    return false
  end

end
