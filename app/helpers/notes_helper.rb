require 'cgi'

module NotesHelper
  
  def generate_notes_thread(thread, params = {})
    html = ""
    thread.each { |note| html << process_thread(note, params) }
    html
  end

  def process_thread(note, params = {})
    if params[:collapsed]
      collapsed = "collapsed"
      display = "none"
    else
      collapsed = ""
      display = "block"
    end
    
    html1 = <<-html
      <div class="response_container">
        <div class="response" id="note_#{note.id}">
          <div class="note_corner">&nbsp;</div>
          <div class="response_head #{collapsed}">
            <span class="response_collapse"><span class="response_title">#{note.subject}</span> by <span class="response_author">#{get_username(note.author)}</span> <span class="response_date">#{time_ago_in_words(Time.at(convert_java_time(note.created.to_i)))} ago</span></span>
          </div>
          <div id="note_#{note.id}_collapse" class="collapsible" style="display: #{display};">
            <div class="response_body">
              #{note.body}
            </div>
            <div class="create_reply_container"><a class="create_reply" note_id="#{note.id}" href="javascript:void(0)">reply</a></div>
            <div class="reply_compose" id="note_#{note.id}_reply">
              <div id="reply_#{note.id}" class="reply_form_container"></div>
              <a href="javascript:void(0)" note_id="#{note.id}" class="cancel_reply">cancel</a>
            </div>
          </div>
          <div class="spacer"></div>
          <div class="response_children">
    html
    
    html2 = note.associated.empty? ? "" : generate_notes_thread(note.associated, params) 
    
    html3 = <<-html
          </div>
        </div>
      </div>
    html
    
    html1 + html2 + html3
  end
  
  def get_applies_to_link(ontology_id, type, id)
    # We don't use helper methods (like link_to or url_for) here because this can get called from the controller
    begin
      case type
      when "Class"
        return "<a href='/visualize/#{ontology_id}/?conceptid=#{CGI.escape(id)}'>#{DataAccess.getNode(ontology_id, id).label}</a>"
      when "Note"
        ontology = DataAccess.getOntology(ontology_id)
        return "<a href='/notes/virtual/#{ontology.ontologyId}?noteid=#{id}'>#{DataAccess.getNote(ontology.ontologyId, id).subject}</a>" 
      when "Individual"
      when "Property"
      when "Ontology"
        ontology = DataAccess.ontology(ontology_id)
        return "<a href='/ontologies/virtual/#{ontology.ontologyId}'>#{ontology.displayLabel}</a>" 
      end
    rescue Exception => e
      return "Unknown or Deprecated #{type}"
    end
  end
  
end
