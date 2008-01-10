# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ba3e1ab68d3ab8bd1a1e109dfad93d30'
  
  def undo_param(name)
    name.gsub('_'," ")
  end
  
end
