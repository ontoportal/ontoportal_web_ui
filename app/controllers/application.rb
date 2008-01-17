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
  
  def redirect_to_browse
    redirect_to "/ontologies"
  end
  
  def redirect_to_home
    redirect_to "/"
  end
  
  def authorize
    unless session[:user]
      flash[:notice] = "Please log in"
      redirect_to_home
    end
  end
  
  def isAdmin
    if session[:user].nil? || !session[:user].admin
      return false
    else
      return true
    end
  
  end

  def authorize_owner(id=nil?)
    if id.nil? 
      id = params[:id].to_i
    end
    
     if session[:user].nil?
        redirect_to_home
     else
       unless session[:user].id.eql?(id) || session[:user].admin
         redirect_to_home      
       end
     end
     
  end 
  
  
end
