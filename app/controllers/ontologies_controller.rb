class OntologiesController < ApplicationController

  require 'cgi'

  #caches_page :index

  helper :concepts
  layout 'ontology'

  before_filter :authorize_and_redirect, :only=>[:edit,:update,:create,:new]

  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include: "name,acronym,projects,notes,group,reviews,administeredBy,hasDomain,viewingRestriction")
    @submissions = LinkedData::Client::Models::OntologySubmission.all
    @submissions_map = Hash[@submissions.map {|sub| [sub.ontology.acronym, sub] }]
    @categories = LinkedData::Client::Models::Category.all
    @groups = LinkedData::Client::Models::Group.all
    @term_counts = {}
    @mapping_counts = {}
    @note_counts = {}

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    # This action is now a router using the 'p' parameter as the page to show
    case params[:p]
    when "terms"
      self.terms
      return
    when "mappings"
      self.mappings
      return
    when "notes"
      self.notes
      return
    when "widgets"
      self.widgets
      return
    when "summary"
      self.summary
      return
    else
      self.summary
      return
    end
  end

  def virtual
    @ontology = DataAccess.getLatestOntology(params[:ontology])

    @versions = DataAccess.getOntologyVersions(@ontology.ontologyId).sort{|x,y| x.id <=> y.id}

    LOG.add :info, 'show_virtual_ontology', request, :virtual_id => @ontology.ontologyId, :ontology_name => @ontology.displayLabel

    if @ontology.statusId.to_i.eql?(3)
      redirect_to "/ontologies/#{@ontology.id}"
      return
    else
      for version in @versions
        if version.statusId.to_i.eql?(3)
          redirect_to "/ontologies/#{version.id}"
          return
        end
      end
    end
    redirect_to "/ontologies/#{@ontology.id}"
    return
  end

  def download_latest
    @ontology = DataAccess.getLatestOntology(params[:id])
    redirect_to $REST_URL + "/ontologies/download/#{@ontology.id}?apikey=#{$API_KEY}"
  end

  def visualize
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:conceptid] = params[:id].nil? ? params[:conceptid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:ontologyid] : params[:ontology]

    # Error checking
    if params[:ontology].nil? || params[:id] && params[:ontology].nil?
      @error = "Please provide an ontology id or concept id with an ontology id."
      return
    end

    params_array = []
    params.each do |key,value|
      stop_words = [ "ontology", "controller", "action" ]
      next if stop_words.include?(key.to_s) || value.nil? || value.empty?
      params_array << "#{key}=#{CGI.escape(value)}"
    end
    params_string = (params_array.empty?) ? "" : "&#{params_array.join('&')}"

    redirect_to "/ontologies/#{params[:ontology]}?p=terms#{params_string}", :status => :moved_permanently
  end

  # GET /visualize/:ontology
  def terms
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]

    view = false
    if params[:view]
      view = true
    end

    # Set the ontology we are viewing
    if view
      # TODO_REV: Add view support when REST support is available
      # @ontology = DataAccess.getView(params[:ontology])
    else
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end

    @submission = @ontology.explore.latest_submission

    # TODO_REV: Support private ontologies
    # if @ontology.private? && (session[:user].nil? || !session[:user].has_access?(@ontology))
    #   if request.xhr?
    #     return render :partial => 'private_ontology', :layout => false
    #   else
    #     return render :partial => 'private_ontology', :layout => "ontology_viewer"
    #   end
    # end

    # TODO_REV: Support licensed ontologies
    # if @ontology.licensed? && (session[:user].nil? || !session[:user].has_access?(@ontology))
    #   @user = UserWrapper.new
    #   if request.xhr?
    #     return render :partial => 'licensed_ontology', :layout => false
    #   else
    #     return render :partial => 'licensed_ontology', :layout => "ontology_viewer"
    #   end
    # end

    # TODO_REV: Redirect to most recent parsed version when archived or bad parse

    # TODO_REV: Output RDF as necessary (we may delegate this to the REST service)

    get_class(params)

    # set the current PURL for this term
    @current_purl = @concept.id.start_with?("http://") ? "#{$PURL_PREFIX}/#{@ontology.acronym}?conceptid=#{CGI.escape(@concept.id)}" : "#{$PURL_PREFIX}/#{@ontology.abbreviation}/#{CGI.escape(@concept.id)}" if $PURL_ENABLED

    # TODO_REV: Mappings for classes
    # gets the initial mappings
    # @mappings = DataAccess.getConceptMappings(@concept.ontology.ontologyId, @concept.fullId)

    # TODO_REV: Support notes deletion
    # check to see if user should get the option to delete
    # @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    @notes = @concept.explore.notes

    unless @concept.id.to_s.empty?
      # Update the tab with the current concept
      update_tab(@ontology,@concept.id)
    end

    if request.xhr?
      return render 'visualize', :layout => false
    else
      return render 'visualize', :layout => "ontology_viewer"
    end
  end

  def new
    if (params[:id].nil?)
      @ontology = LinkedData::Client::Models::Ontology.new
      @ontology.administeredBy = [session[:user].id]
    else
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def new_view
    if(params[:id].nil? || params[:id].to_i < 1)
      @new = true
      @ontology = OntologyWrapper.new
      @ontology_version_id = params[:version_id]
      @ontology.administeredBy = session[:user].id
    else
      @ontology = DataAccess.getView(params[:id])
    end

    @categories = DataAccess.getCategories()
  end


  def create
    @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
    @ontology_saved = @ontology.save

    if @ontology_saved.errors
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(@ontology_saved)
      @errors = {acronym: "Acronym already exists, please use another"} if @ontology_saved.status == 409

      if (@ontology.viewOf)
        render :action => 'new_view'
      else
        render :action => 'new'
      end
    else
      # Adds ontology to syndication
      # Don't break here if we encounter problems, the RSS feed isn't critical
      # TODO_REV: What should we do about RSS / Syndication?
      # begin
      #   event = EventItem.new
      #   event.event_type="Ontology"
      #   event.event_type_id=@ontology.id
      #   event.ontology_id=@ontology.ontologyId
      #   event.save
      # rescue
      # end

      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end

      if @ontology_saved.summaryOnly
        redirect_to "/ontologies/success/#{CGI.escape(@ontology.id)}"
      else
        redirect_to new_ontology_submission_url
      end
    end
  end

  def submit_success
    @ontology = LinkedData::Client::Models::Ontology.get(params[:id])
    render :partial => "submit_success", :layout => "ontology"
  end

  def update
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology][:acronym]).first
    @ontology.update_from_params(params[:ontology])
    error_response = @ontology.update

    if error_response
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(error_response)
      @errors = {acronym: "Acronym already exists, please use another"} if error_response.status == 409

      if (@ontology.viewOf)
        render :action => 'new_view'
      else
        render :action => 'new'
      end
    else
      # Adds ontology to syndication
      # Don't break here if we encounter problems, the RSS feed isn't critical
      # TODO_REV: What should we do about RSS / Syndication?
      # begin
      #   event = EventItem.new
      #   event.event_type="Ontology"
      #   event.event_type_id=@ontology.id
      #   event.ontology_id=@ontology.ontologyId
      #   event.save
      # rescue
      # end

      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end

      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  def edit
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    redirect_to_home unless session[:user] && @ontology.administeredBy.include?(session[:user].id) || session[:user].admin?
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def edit_view
    @ontology = DataAccess.getView(params[:id])

    authorize_owner(@ontology.administeredBy)

    @categories = DataAccess.getCategories()
  end



  ###############################################
  ## These are stub methods that let us invoke partials directly
  ###############################################
  def summary
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    @submission = @ontology.explore.latest_submission

    # Check to see if user is requesting RDF+XML, return the file from REST service if so
    if request.accept.to_s.eql?("application/rdf+xml")
      user_api_key = session[:user].nil? ? "" : session[:user].apikey
      begin
        rdf_file = RemoteFile.new($REST_URL + "/virtual/ontology/rdf/download/#{@ontology.ontologyId}?apikey=#{$API_KEY}&userapikey=#{user_api_key}")
      rescue Exception => e
        if !e.io.status.nil? && e.io.status[0].to_i == 404
          raise Error404
        end
      end
      send_file rdf_file.path, :type => "appllication/rdf+xml"
      return
    end

    # Grab Metadata
    # @groups = DataAccess.getGroups()
    # @categories = DataAccess.getCategories()
    # @versions = DataAccess.getOntologyVersions(@ontology.ontologyId)
    # @versions.sort!{|x,y| y.internalVersion.to_i<=>x.internalVersion.to_i}
    # @metrics = DataAccess.getOntologyMetrics(@ontology.id)

    # Check to see if the metrics are from the most recent ontology version
    # if !@metrics.nil? && !@metrics.id.eql?(@ontology.id)
    #   @old_metrics = @metrics
    #   @old_ontology = DataAccess.getOntology(@old_metrics.id)
    # end

    # @diffs = DataAccess.getDiffs(@ontology.ontologyId)

    #Grab Reviews Tab
    @reviews = @ontology.explore.reviews
    @reviews.sort! {|a,b| b.created <=> a.created}

    #Grab projects tab
    @projects = @ontology.explore.projects

    if request.xhr?
      render :partial => 'metadata', :layout => false
    else
      render :partial => 'metadata', :layout => "ontology_viewer"
    end
  end

  def mappings
    ontology_list = DataAccess.getOntologyList()
    view_list = DataAccess.getViewList()
    @ontology = DataAccess.getOntology(params[:id])
    @ontologies_mapping_count = DataAccess.getMappingCountBetweenOntologies(@ontology.ontologyId)

    ontologies_hash = {}
    ontology_list.each do |ontology|
      ontologies_hash[ontology.ontologyId] = ontology
    end

    view_list.each do |view|
      ontologies_hash[view.ontologyId] = view
    end

    # Add ontologies to the mapping count array, delete if no ontology exists
    @ontologies_mapping_count.delete_if do |ontology|
      ontology['ontology'] = ontologies_hash[ontology['ontologyId']]
      if ontology['ontology'].nil?
        true
      else
        false
      end
    end

    @ontology_id = @ontology.ontologyId
    @ontology_label = @ontology.displayLabel

    @ontologies_mapping_count.sort! {|a,b| a['ontology'].displayLabel.downcase <=> b['ontology'].displayLabel.downcase } unless @ontologies_mapping_count.nil? || @ontologies_mapping_count.length == 0

    if request.xhr?
      render :partial => 'mappings', :layout => false
    else
      render :partial => 'mappings', :layout => "ontology_viewer"
    end
  end

  def notes
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    @submission = @ontology.explore.latest_submission
    @notes = @ontology.explore.notes

    @notes_deletable = false
    # TODO_REV: Handle notes deletion
    # @notes.each {|n| @notes_deletable = true if n.deletable?(session[:user])} if @notes.kind_of?(Array)

    @note_link = "/ontologies/#{@ontology.acronym}/notes/"
    if request.xhr?
      render :partial => 'notes', :layout => false
    else
      render :partial => 'notes', :layout => "ontology_viewer"
    end
  end

  def widgets
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    if request.xhr?
      render :partial => 'widgets', :layout => false
    else
      render :partial => 'widgets', :layout => "ontology_viewer"
    end
  end

  private

  def validate(params, update=false)
    # strip all spaces from email
    params[:contactEmail] = params[:contactEmail].gsub(" ", "")

    acronyms = LinkedData::Client::Models::Ontology.all.map {|o| o.acronym}

    errors=[]
    if params[:displayLabel].nil? || params[:displayLabel].length <1
      errors << "Please Enter an Ontology Name"
    end

    if params[:abbreviation].nil? || params[:abbreviation].empty?
      errors << "Please Enter an Ontology Abbrevation"
    elsif params[:abbreviation].include?(" ") || /[\^{}\[\]:;\$=\*`#\|@'\<>\(\)\+,\\\/]/.match(params[:abbreviation])
      errors << "Abbreviations cannot contain spaces or the following characters: <span style='font-family: monospace;'>^{}[]:;$=*`#|@'<>()\+,\\/</span>"
    elsif params[:abbreviation].length < 2
      errors << "Abbreviation must be at least two characters"
    elsif params[:abbreviation].length > 16
      errors << "Abbreviations must be 16 characters or less"
    elsif !/^[A-Za-z]/.match(params[:abbreviation])
      errors << "Abbreviations must start with a letter"
    elsif DataAccess.getOntologyAcronyms.include?(params[:abbreviation].downcase)
      # We matched an existing acronym, but is it already ours from a previous version?
      unless update && !DataAccess.getLatestOntology(params[:ontologyId]).nil? && DataAccess.getLatestOntology(params[:ontologyId]).abbreviation.downcase.eql?(params[:abbreviation].downcase)
        errors << "That abbreviation is already in use. Please choose another."
      end
    end

    if params[:dateReleased].nil? || params[:dateReleased].length < 1
      errors << "Please Enter the Date Released"
    elsif params[:dateReleased].match(/[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}/).nil?
      errors << "Please Enter a Date Formatted as MM/DD/YYYY"
    end

    unless update
      if params[:isRemote].to_i.eql?(0) && (params[:filePath].nil? || params[:filePath].length < 1)
        errors << "Please Choose a File"
      end

      if params[:isRemote].to_i.eql?(0) && !params[:filePath].nil? && params[:filePath].size.to_i > $MAX_UPLOAD_SIZE && !session[:user].admin?
        errors << "File is too large"
      end

      if params[:isRemote].to_i.eql?(1) && (params[:pullLocation].nil? || params[:pullLocation].length < 1)
        errors << "Please Enter a URL"
      end

      if params[:isRemote].to_i.eql?(1) && (!params[:pullLocation].nil? || params[:pullLocation].length > 1)
        begin
          pullLocation = URI.parse(params[:pullLocation])
          if pullLocation.scheme.nil? || pullLocation.host.nil?
            errors << "Please enter a valid URL"
          end
        rescue URI::InvalidURIError
          errors << "Please enter a valid URL"
        end

        if !remote_file_exists?(params[:pullLocation])
          errors << "The URL you provided for us to load an ontology from doesn't reference a valid file"
        end
      end
    end

    if params[:contactName].nil? || params[:contactName].length < 1
      errors << "Please Enter the Contact Name"
    end

    if params[:contactEmail].nil? || params[:contactEmail].length <1 || !params[:contactEmail].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      errors << "Please Enter the Contact Email"
    end

    # Check for metadata only and set parameter
    if params[:isRemote].to_i.eql?(3)
      params[:isMetadataOnly] = 1
    end

    return errors
  end

end
