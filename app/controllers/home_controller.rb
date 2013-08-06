class HomeController < ApplicationController
  layout 'ontology'

  RI_OPTIONS = {:apikey => $API_KEY, :resource_index_location => "http://#{$REST_DOMAIN}/resource_index/", :limit => 10, :mode => :intersection}

  def index
    @ontologies = LinkedData::Client::Models::Ontology.all
    @groups = LinkedData::Client::Models::Group.all

    # TODO_REV: List of recent notes (just get all notes and sort by date in code)
    # active_onts_by_notes_query = "select ontology_id,count(ontology_id) as note_count from notes_indices as note group by ontology_id order by note_count desc"
    # @active_totals = ActiveRecord::Base.connection.select_rows(active_onts_by_notes_query);

    # TODO_REV: List of recent mappings (discuss with Manuel)
    @last_notes = []

    # TODO_REV: Handle custom ontology sets
    # Show only notes from custom ontology set
    @last_mappings = []

    # TODO_REV: Handle private ontologies
    # Hide notes from private ontologies
    # restricted_ontologies = DataAccess.getRestrictedOntologyList
    # restricted_for_query = []
    # restricted_ontologies.each do |ont|
    #   restricted_for_query << ont.ontologyId.to_i unless session[:user] && session[:user].has_access?(ont)
    # end

    # calculate number of total RI records that have been processed
    @ri_record_count = "TODO"
    @direct_annotations = "TODO"
    @direct_expanded_annotations = "TODO"
    @direct_expanded_annotations = "TODO"
    @number_of_resources = "TODO"
  end

  def release
    redirect_to :controller => 'home', :action => 'help'
  end

  def help
    # Show the header/footer or not
    layout = params[:pop].eql?("true") ? "popup" : "ontology"
    render :layout => layout
  end

  def recommender

  end

  def annotate

  end

  def all_resources
    @conceptid = params[:conceptid]
    @ontologyid = params[:ontologyid]
    @ontologyversionid = params[:ontologyversionid]
    @search = params[:search]
  end

  def feedback
    # Show the header/footer or not
    feedback_layout = params[:pop].eql?("true") ? "popup" : "ontology"

    # We're using a hidden form field to trigger for error checking
    # If sim_submit is nil, we know the form hasn't been submitted and we should
    # bypass form processing.
    if params[:sim_submit].nil?
      render :layout => feedback_layout
      return
    end

    @errors = []

    if params[:name].nil? || params[:name].empty?
      @errors << "Please include your name"
    end
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      @errors << "Please include your email"
    end
    if params[:comment].nil? || params[:comment].empty?
      @errors << "Please include your comment"
    end
    # verify_recaptcha is a method provided by the recaptcha plugin, returns true or false.
    if ENV['USE_RECAPTCHA'] == 'true' && !session[:user]
      if !verify_recaptcha
        @errors << "Please fill in the proper text from the supplied image"
      end
    end

    unless @errors.empty?
      render :layout => feedback_layout
      return
    end

    Notifier.deliver_feedback(params[:name],params[:email],params[:comment],params[:location])

    if params[:pop].eql?("true")
      render :action => "feedback_complete", :layout => "popup"
    else
      flash[:notice]="Feedback has been sent"
      redirect_to_home
    end
  end

  def user_intention_survey
    render :partial => "user_intention_survey", :layout => false
  end

  def robots
    if @subdomain_filter[:active]
      robots = <<-EOF.gsub(/^\s+/, "")
        User-agent: *\n
        Disallow: /
      EOF
      render :text => robots, :content_type => 'text/plain'
    else
      robots = <<-EOF.gsub(/^\s+/, "")
        User-Agent: *
        Disallow:
      EOF
      render :text => robots, :content_type => 'text/plain'
    end
  end

  def account
    @title = "Account Information"
    if session[:user].nil?
      redirect_to :controller => 'login', :action => 'index', :redirect => "/account"
      return
    end

    @user_ontologies = session[:user_ontologies]
    @user_ontologies ||= {}

    @user = LinkedData::Client::Models::User.get(session[:user].id, include: "all")

    render :partial => "users/details", :layout => "ontology"
  end

  def feedback_complete
  end

end
