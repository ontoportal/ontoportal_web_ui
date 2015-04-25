
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
    @ontology = LinkedData::Client::Models::Ontology.get(CGI.unescape(params["acronym"])) rescue nil
    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params["acronym"]).first unless @ontology
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
        @status = "Cache successfully flushed"
      rescue Exception => e
        @status = "Error: problem flushing the cache - #{e.message}"
      end
    else
      @status = "Error: the cache does not respond to the 'flush_all' command"
    end
    render :partial => "status"
  end

  def resetcache
    if @cache.respond_to?(:reset)
      begin
        @cache.reset
        @status = "Cache connection successfully reset"
      rescue Exception => e
        @status = "Error: problem resetting the cache connection - #{e.message}"
      end
    else
      @status = "Error: the cache does not respond to the 'reset' command"
    end
    render :partial => "status"
  end

  def delete_ontology
    @status = "Ontology #{params["acronym"]} and all its artifacts deleted successfully"
    begin
      ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params["acronym"]).first

      if ontology
        error_response = ontology.delete

        if error_response
          @status = "Error: "
          @errors = response_errors(error_response) # see application_controller::response_errors
          @errors.each {|k, v| @status << "#{v}, "}
          @status = @status[0...-2]
        end
      else
        @status = "Error: Ontology #{params["acronym"]} was not found in the system"
      end
    rescue Exception => e
      @status = "Error: problem deleting ontology #{params["acronym"]} - #{e.message}"
    end
    render :partial => "status"
  end

  def delete_submssion
    puts "Deleting submission #{params["id"]} of ontology #{params["acronym"]}"
  end

  private

  def cache_setup
    @cache = Rails.cache.instance_variable_get("@data")
  end

end
