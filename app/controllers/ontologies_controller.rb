class OntologiesController < ApplicationController

  require 'cgi'

  #caches_page :index

  helper :concepts
  layout :resolve_layout

  before_filter :authorize_and_redirect, :only=>[:edit,:update,:create,:new]

  KNOWN_PAGES = Set.new(["terms", "classes", "mappings", "notes", "widgets", "summary"])

  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include: LinkedData::Client::Models::Ontology.include_params)
    @submissions = LinkedData::Client::Models::OntologySubmission.all
    @submissions_map = Hash[@submissions.map {|sub| [sub.ontology.acronym, sub] }]
    @categories = LinkedData::Client::Models::Category.all
    @groups = LinkedData::Client::Models::Group.all

    # Count the number of classes in each ontology
    metrics_hash = get_metrics_hash
    @class_counts = {}
    @ontologies.each do |o|
      @class_counts[o.id] = metrics_hash[o.id].classes if metrics_hash[o.id]
      @class_counts[o.id] ||= 0
    end

    @mapping_counts = {}
    @note_counts = {}
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def browse
    @app_name = "FacetedBrowsing"
    @app_dir = "/browse"
    @base_path = @app_dir
    @ontologies = LinkedData::Client::Models::Ontology.all(include: LinkedData::Client::Models::Ontology.include_params + ",viewOf", include_views: true)

    submissions = LinkedData::Client::Models::OntologySubmission.all(include_views: true)
    submissions_map = Hash[submissions.map {|sub| [sub.ontology.acronym, sub] }]

    @categories = LinkedData::Client::Models::Category.all
    @groups = LinkedData::Client::Models::Group.all

    reviews = {}
    LinkedData::Client::Models::Review.all.each do |r|
      reviews[r.reviewedOntology] ||= []
      reviews[r.reviewedOntology] << r
    end

    metrics_hash = get_metrics_hash

    @formats = Set.new

    @ontologies.each do |o|
      if metrics_hash[o.id]
        o.class_count = metrics_hash[o.id].classes
      else
        o.class_count = 0
      end

      o.type = o.viewOf.nil? ? "ontology" : "ontology_view"
      o.show = o.viewOf.nil? ? true : false # show ontologies only by default
      o.reviews = reviews[o.id]

      o.submission = submissions_map[o.acronym]
      next unless o.submission

      @formats << o.submission.hasOntologyLanguage

      creation_date = DateTime.parse(o.submission.creationDate)
      o.creationDateFormatted = l(creation_date, format: "%m/%d/%Y")
    end
  end

  # GET /visualize/:ontology
  def classes
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]
    # Set the ontology we are viewing
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    # Get the latest 'ready' submission, or fallback to any latest submission
    @submission = get_ontology_submission_ready(@ontology)  # application_controller

    get_class(params)   # application_controller::get_class

    if request.accept.to_s.eql?("application/ld+json") || request.accept.to_s.eql?("application/json")
      headers['Content-Type'] = request.accept.to_s
      render text: @concept.to_jsonld
      return
    end

    # set the current PURL for this class
    @current_purl = @concept.purl if $PURL_ENABLED

    begin
      @mappings = @concept.explore.mappings
    rescue Exception => e
      msg = ''
      if @concept.instance_of?(LinkedData::Client::Models::Class) &&
          @ontology.instance_of?(LinkedData::Client::Models::Ontology)
        msg = "Failed to explore mappings for #{@concept.id} in #{@ontology.id}"
      end
      LOG.add :error, msg + "\n" + e.message
      @mappings = []
    end
    @delete_mapping_permission = check_delete_mapping_permission(@mappings)

    begin
      @notes = @concept.explore.notes
    rescue Exception => e
      msg = ''
      if @concept.instance_of?(LinkedData::Client::Models::Class) &&
          @ontology.instance_of?(LinkedData::Client::Models::Ontology)
        msg = "Failed to explore notes for #{@concept.id} in #{@ontology.id}"
      end
      LOG.add :error, msg + "\n" + e.message
      @notes = []
    end

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

  def create
    if params['commit'] == 'Cancel'
      redirect_to "/ontologies"
      return
    end
    @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
    @ontology_saved = @ontology.save
    if !@ontology_saved || @ontology_saved.errors
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(@ontology_saved)
      #@errors = {acronym: "Acronym already exists, please use another"} if @ontology_saved.status == 409
      render "new"
    else
      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end
      if @ontology_saved.summaryOnly
        redirect_to "/ontologies/success/#{@ontology.acronym}"
      else
        redirect_to new_ontology_submission_url(CGI.escape(@ontology_saved.id))
      end
    end
  end

  def edit
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    redirect_to_home unless session[:user] && @ontology.administeredBy.include?(session[:user].id) || session[:user].admin?
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def mappings
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    counts = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}/mappings/statistics/ontologies/#{params[:id]}")
    @ontologies_mapping_count = []
    unless counts.nil?
      counts.members.each do |acronym|
        count = counts[acronym]
        # Note: find_by_acronym includes ontology views
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

  def new
    if (params[:id].nil?)
      @ontology = LinkedData::Client::Models::Ontology.new(values: params[:ontology])
      @ontology.administeredBy = [session[:user].id]
    else
      # Note: find_by_acronym includes ontology views
      @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology]).first
    end
    @categories = LinkedData::Client::Models::Category.all
    @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
    @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
  end

  def notes
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    # Get the latest 'ready' submission, or fallback to any latest submission
    @submission = get_ontology_submission_ready(@ontology)  # application_controller
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

  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    # Hack to make ontologyid and conceptid work in addition to id and ontology params
    params[:id] = params[:id].nil? ? params[:ontologyid] : params[:id]
    params[:ontology] = params[:ontology].nil? ? params[:id] : params[:ontology]

    # PURL-specific redirect to handle /ontologies/{ACR}/{CLASS_ID} paths
    if params[:purl_conceptid]
      if params[:conceptid]
        params.delete(:purl_conceptid)
      else
        params[:conceptid] = params.delete(:purl_conceptid)
      end
      redirect_to "/ontologies/#{params[:acronym]}?p=classes#{params_string_for_redirect(params, prefix: "&")}", :status => :moved_permanently
      return
    end

    if params[:ontology].to_i > 0
      acronym = BPIDResolver.id_to_acronym(params[:ontology])
      if acronym
        redirect_new_api
        return
      end
    end

    # Fix parameters to only use known pages
    params[:p] = nil unless KNOWN_PAGES.include?(params[:p])

    # This action is now a router using the 'p' parameter as the page to show
    case params[:p]
      when "terms"
        params[:p] = 'classes'
        redirect_to "/ontologies/#{params[:ontology]}#{params_string_for_redirect(params)}", :status => :moved_permanently
        return
      when "classes"
        self.classes #rescue self.summary
        return
      when "mappings"
        self.mappings #rescue self.summary
        return
      when "notes"
        self.notes #rescue self.summary
        return
      when "widgets"
        self.widgets #rescue self.summary
        return
      when "summary"
        self.summary
        return
      else
        self.summary
        return
    end
  end

  def submit_success
    @acronym = params[:id]
    # Force the list of ontologies to be fresh by adding a param with current time
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id], cache_invalidate: Time.now.to_i).first
    render :partial => "submit_success", :layout => "ontology"
  end

  def summary
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    raise Error404 if @ontology.nil?
    # Check to see if user is requesting RDF+XML, return the file from REST service if so
    if request.accept.to_s.eql?("application/ld+json") || request.accept.to_s.eql?("application/json")
      headers['Content-Type'] = request.accept.to_s
      render text: @ontology.to_jsonld
      return
    end
    # Explore the ontology links
    @metrics = @ontology.explore.metrics rescue []
    @reviews = @ontology.explore.reviews.sort {|a,b| b.created <=> a.created} || []
    @projects = @ontology.explore.projects.sort {|a,b| a.name.downcase <=> b.name.downcase } || []
    # retrieve submissions in descending submissionId order, should be reverse chronological order.
    @submissions = @ontology.explore.submissions.sort {|a,b| b.submissionId <=> a.submissionId } || []
    LOG.add :error, "No submissions for ontology: #{@ontology.id}" if @submissions.empty?
    # Get the latest submission, not necessarily the latest 'ready' submission
    @submission_latest = @ontology.explore.latest_submission rescue @ontology.explore.latest_submission(include: "")
    @views = @ontology.explore.views.sort {|a,b| a.acronym.downcase <=> b.acronym.downcase } || []
    if request.xhr?
      render :partial => 'metadata', :layout => false
    else
      render :partial => 'metadata', :layout => "ontology_viewer"
    end
  end

  def update
    if params['commit'] == 'Cancel'
      acronym = params['id']
      redirect_to "/ontologies/#{acronym}"
      return
    end
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:ontology][:acronym] || params[:id]).first
    @ontology.update_from_params(params[:ontology])
    error_response = @ontology.update
    if error_response
      @categories = LinkedData::Client::Models::Category.all
      @user_select_list = LinkedData::Client::Models::User.all.map {|u| [u.username, u.id]}
      @user_select_list.sort! {|a,b| a[1].downcase <=> b[1].downcase}
      @errors = response_errors(error_response)
      @errors = {acronym: "Acronym already exists, please use another"} if error_response.status == 409
    else
      # TODO_REV: Enable subscriptions
      # if params["ontology"]["subscribe_notifications"].eql?("1")
      #  DataAccess.createUserSubscriptions(@ontology.administeredBy, @ontology.ontologyId, NOTIFICATION_TYPES[:all])
      # end
      redirect_to "/ontologies/#{@ontology.acronym}"
    end
  end

  def virtual
    redirect_new_api
  end

  def visualize
    redirect_new_api(true)
  end

  def widgets
    # Note: find_by_acronym includes ontology views
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
    if request.xhr?
      render :partial => 'widgets', :layout => false
    else
      render :partial => 'widgets', :layout => "ontology_viewer"
    end
  end

  private

  def resolve_layout
    case action_name
    when 'browse'
      'angular'
    else
      'ontology'
    end
  end

end
