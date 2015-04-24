
class AdminController < ApplicationController
  layout 'ontology'
  before_action :cache_setup

  DEBUG_BLACKLIST = [:"$,", :$ADDITIONAL_ONTOLOGY_DETAILS, :$rdebug_state, :$PROGRAM_NAME, :$LOADED_FEATURES, :$KCODE, :$-i, :$rails_rake_task, :$$, :$gems_build_rake_task, :$daemons_stop_proc, :$VERBOSE, :$DAEMONS_ARGV, :$daemons_sigterm, :$DEBUG_BEFORE, :$stdout, :$-0, :$-l, :$-I, :$DEBUG, :$', :$gems_rake_task, :$_, :$CODERAY_DEBUG, :$-F, :$", :$0, :$=, :$FILENAME, :$?, :$!, :$rdebug_in_irb, :$-K, :$TESTING, :$fileutils_rb_have_lchmod, :$EMAIL_EXCEPTIONS, :$binding, :$-v, :$>, :$SAFE, :$/, :$fileutils_rb_have_lchown, :$-p, :$-W, :$:, :$__dbg_interface, :$stderr, :$\, :$&, :$<, :$debug, :$;, :$~, :$-a, :$DEBUG_RDOC, :$CGI_ENV, :$LOAD_PATH, :$-d, :$*, :$., :$-w, :$+, :$@, :$`, :$stdin, :$1, :$2, :$3, :$4, :$5, :$6, :$7, :$8, :$9]
  ADMIN_URL = "#{LinkedData::Client.settings.rest_url}/admin/"
  ONTOLOGIES_URL = "#{ADMIN_URL}report"

  def index
    if session[:user].nil? || !session[:user].admin?
      redirect_to :controller => 'login', :action => 'index', :redirect => '/admin'
    else
      start = Time.now
      form_data = Hash.new
      ontologies_data = LinkedData::Client::HTTP.get(ONTOLOGIES_URL, form_data, raw: true)
      ontologies_data_parsed = JSON.parse(ontologies_data)
      @ontologies = ontologies_data_parsed["ontologies"]
      @report_date = ontologies_data_parsed["date_generated"]

      LOG.add :debug, "Retrieved #{@ontologies.length} ontologies: #{Time.now - start}s"
      # render json: problem_ontologies
      render action: "index"
    end

    # globals =  global_variables - DEBUG_BLACKLIST
    # @globals = {}
    # globals.each {|g| @globals[g.to_s] = eval(g.to_s)}
  end

  def show
    puts "executing show"
  end

  def submissions
    @submissions = nil
    @ontology = LinkedData::Client::Models::Ontology.get(CGI.unescape(params["id"])) rescue nil
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params["id"]).first unless @ontology
    begin
      submissions = @ontology.explore.submissions
      @submissions = submissions.sort {|a,b| b.submissionId <=> a.submissionId }
    rescue
      @submissions = []
    end
    render :partial => "layouts/ontology_report_submissions"
  end

  def clearcache
    if @cache.respond_to?(:flush_all)
      begin
        @cache.flush_all
      rescue
        @status = "There was a problem flushing the cache"
      end

      @status = "Cache successfully flushed"
    else
      @status = "Error: the cache does not respond to the `flush_all` command"
    end
    render :partial => "status"
  end

  def resetcache
    if @cache.respond_to?(:reset)
      begin
        @cache.reset
      rescue
        @status = "There was a problem reseting the cache connection"
      end

      @status = "Cache connection successfully reset"
    else
      @status = "Error: the cache does not respond to the `reset` command"
    end
    render :partial => 'status'
  end

  def delete_ontology
    puts "Deleting ontology #{params["id"]}"
    ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params["id"]).first
    error_response = ontology.delete
    render :json => {:success => "Ontology #{params["id"]} and all its artifacts deleted successfully."}
  end

  private

  def cache_setup
    @cache = Rails.cache.instance_variable_get("@data")
  end

end
