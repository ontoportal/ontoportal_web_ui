class HomeController < ApplicationController
  layout 'ontology'

  RI_OPTIONS = {:apikey => $API_KEY, :resource_index_location => "#{$REST_URL}/resource_index/", :limit => 10, :mode => :intersection}

  NOTES_RECENT_MAX = 5

  def index
    @ontologies = LinkedData::Client::Models::Ontology.all
    @groups = LinkedData::Client::Models::Group.all

    # TODO: Handle custom ontology sets
    # Show only notes from custom ontology set
    @notes = LinkedData::Client::Models::Note.all
    @last_notes = []
    @notes.sort! {|a,b| b.created <=> a.created }
    @notes[0..20].each do |n|
      ont_uri = n.relatedOntology.first
      ont = LinkedData::Client::Models::Ontology.find(ont_uri)
      next if ont.nil?
      username = n.creator.split("/").last
      note = {
          :uri => n.links['ui'],
          :id => n.id,
          :subject => n.subject,
          :body => n.body,
          :created => n.created,
          :author => username,
          :ont_name => ont.name
      }
      @last_notes.push note
      break if @last_notes.length >= NOTES_RECENT_MAX  # 5
    end
    # Get the latest manual mappings
    # All mapping classes are bidirectional.
    # Each class in the list maps to all other classes in the list.
    @last_mappings = LinkedData::Client::HTTP.get("#{LinkedData::Client.settings.rest_url}mappings/recent/")
    @classDetails = {}
    if not @last_mappings.empty?
      # There is no 'include' parameter on the /mappings/recent API.
      # The following is required just to get the prefLabel on each mapping class.
      classList = []
      @last_mappings.each do |m|
        m.classes.each do |c|
          classList.push( { :class => c.id, :ontology => c.links['ontology'] } )
        end
      end
      # make the batch call to get all the class prefLabel values
      call_params = {'http://www.w3.org/2002/07/owl#Class'=>{'collection'=>classList, 'include'=>'prefLabel'}}
      classResponse = get_batch_results(call_params)  # method in application_controller.rb
      # Simplify the response data for the UI
      classResults = JSON.parse(classResponse)
      classResults["http://www.w3.org/2002/07/owl#Class"].each do |cls|
        id = cls['@id']
        @classDetails[id] = {
            '@id' => id,
            'ui' => cls['links']['ui'],
            'uri' => cls['links']['self'],
            'prefLabel' => cls['prefLabel'],
            'ontology' => cls['links']['ontology'],
        }
      end
    end
    # TODO_REV: Handle private ontologies
    # Hide notes from private ontologies
    # restricted_ontologies = DataAccess.getRestrictedOntologyList
    # restricted_for_query = []
    # restricted_ontologies.each do |ont|
    #   restricted_for_query << ont.ontologyId.to_i unless session[:user] && session[:user].has_access?(ont)
    # end
    #
    # calculate bioportal summary statistics
    @ont_count = @ontologies.length
    @cls_count = LinkedData::Client::Models::Metrics.all.map {|m| m.classes}.sum
    @resources = get_resource_index_resources # application_controller
    @ri_resources = @resources.length
    @ri_record_count = @resources.map {|r| r.totalElements}.sum
    # retrieve annotation stats from old REST service
    @ri_stats = get_resource_index_annotation_stats
    @direct_annotations = @ri_stats[:direct]
    @direct_expanded_annotations = @ri_stats[:expanded]
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
