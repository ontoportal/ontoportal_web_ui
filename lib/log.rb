require 'rest_client' 

class LOG
  
  # Log using local or remote methods
  #    Local: provide the log level as a symbol (:debug, :info, :error, etc)
  #    Remote: provide the request and a parameter hash
  #       Common Parameters:
  #         :ontology_id
  #         :ontology_name
  #         :virtual_id
  #         :concept_id
  #         :concept_name
  def self.add(level, message, request = nil, remote_params = nil)
    if request
      if $REMOTE_LOGGING.eql?("true")
        remote_log = RestClient::Resource.new $REST_URL + "/log", :timeout => 30
        remote(level, message, request, remote_log, remote_params)
      end
    else
      local(level, message)
    end
  end
  
  private
  
  def self.remote(level, event, request, log, params)
    session = request.session
    params[:user] = session[:user].username rescue ""
    params[:user_id] = session[:user].id rescue ""
    params[:user_ip] = request.remote_ip
    params[:session_id] = session.session_id
    params[:event] = event
    params[:application_id] = $APPLICATION_ID
    params[:request_uri] = request.request_uri
    
    log.post(params)
  end
  
  def self.local(level, message)
    RAILS_DEFAULT_LOGGER.send(level, message)
  end
  
end