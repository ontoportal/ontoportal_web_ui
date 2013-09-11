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
    # Count the number of classes in each ontology
    metrics_hash = get_metrics_hash
    @class_counts = {}
    @ontologies.each do |o|
      begin
        # Using begin:rescue block because some ontologies may not have metrics available.
        @class_counts[o.id] = metrics_hash[o.id].classes
      rescue
        next
      end
    end
    @mapping_counts = {}
    @note_counts = {}

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]

    if params[:ontology].to_i > 0
      acronym = BPIDResolver.id_to_acronym(params[:ontology])
      if acronym
        redirect_new_api
        return
      end
    end

    # This action is now a router using the 'p' parameter as the page to show
    case params[:p]
      when "terms"
        params[:p] = 'classes'
        redirect_to "/ontologies/#{params[:ontology]}#{params_string_for_redirect(params)}", :status => :moved_permanently
        return
      when "classes"
        self.classes
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
    redirect_new_api
  end

  def download_latest
    @ontology = DataAccess.getLatestOntology(params[:id])
    redirect_to $REST_URL + "/ontologies/download/#{@ontology.id}?apikey=#{$API_KEY}"
  end

  def visualize
    redirect_new_api(true)
  end

  # GET /visualize/:ontology
  def classes
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

    # TODO_REV: Enable PURL
    # set the current PURL for this class
    # @current_purl = @concept.id.start_with?("http://") ? "#{$PURL_PREFIX}/#{@ontology.acronym}?conceptid=#{CGI.escape(@concept.id)}" : "#{$PURL_PREFIX}/#{@ontology.abbreviation}/#{CGI.escape(@concept.id)}" if $PURL_ENABLED

    @mappings = @concept.explore.mappings rescue []

    # TODO_REV: Support mappings deletion
    # check to see if user should get the option to delete
    # @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    @notes = @concept.explore.notes rescue []

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
      @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
      @ontology.administeredBy = [session[:user].id]
    else
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
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
        redirect_to new_ontology_submission_url(CGI.escape(@ontology_saved.id))
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

  ###############################################
  ## These are stub methods that let us invoke partials directly
  ###############################################
  def summary
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
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
    # Explore the ontology links
    @categories = @ontology.explore.categories
    @groups = @ontology.explore.groups
    @metrics = @ontology.explore.metrics
    @reviews = @ontology.explore.reviews.sort {|a,b| b.created <=> a.created}
    @projects = @ontology.explore.projects
    @submission = @ontology.explore.latest_submission
    @views = @ontology.explore.views.sort {|a,b| b.acronym <=> a.acronym}  # a list of view ontology models
    # @versions = DataAccess.getOntologyVersions(@ontology.ontologyId)
    # @versions.sort!{|x,y| y.internalVersion.to_i<=>x.internalVersion.to_i}
    # @diffs = @ontology.explore.diffs # Is this access available?
    if request.xhr?
      render :partial => 'metadata', :layout => false
    else
      render :partial => 'metadata', :layout => "ontology_viewer"
    end
  end

  def mappings
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first

    counts = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}mappings/statistics/ontologies/#{params[:id]}")
    @ontologies_mapping_count = []
    unless counts.nil?
      counts.members.each do |acronym|
        count = counts[acronym]
        ontology = LinkedData::Client::Models::Ontology.find_by_acronym(acronym.to_s).first
        next unless ontology
        @ontologies_mapping_count << {'ontology' => ontology, 'count' => count}
      end
      @ontologies_mapping_count.sort! {|a,b| a['ontology'].name.downcase <=> b['ontology'].name.downcase } unless @ontologies_mapping_count.nil? || @ontologies_mapping_count.length == 0
    end

    @ontology_id = @ontology.acronym
    @ontology_label = @ontology.name

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

end
