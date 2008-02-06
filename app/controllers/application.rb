# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ba3e1ab68d3ab8bd1a1e109dfad93d30'
  before_filter  :preload_models
 
 
  def preload_models() # needed for memcache to understand the models in storage
    NodeWrapper
    Annotation
    Mapping
    MarginNote
    OntologyWrapper
    Resource
    TreeNode
  end
  
  
  
 
  def param(name) # Paramaterizes URLs without encoding
    name.gsub(' ',"_")
  end
  
  def undo_param(name) #Undo Paramaterization
    name.gsub('_'," ")
  end
  
  def redirect_to_browse # Redirect to the browse Ontologies page
    redirect_to "/ontologies"
  end
  
  def redirect_to_home # Redirect to Home Page
    redirect_to "/"
  end
  
  def redirect_to_history # Redirects to the correct tab through the history system
    if session[:redirect].nil?
      redirect_to_home
    else
      tab = find_tab(session[:redirect][:ontology])
      session[:redirect]=nil
      redirect_to uri_url (:ontology=>param(tab.ontology),:id=>tab.concept)
    end
  end
  
  
  def authorize  # Verifies if user is logged in
    unless session[:user]
      flash[:notice] = "Please log in"
      redirect_to_home
    end
  end
  
  def isAdmin # Verifies if user is an admin
    if session[:user].nil? || !session[:user].admin
      return false
    else
      return true
    end
  
  end

  def authorize_owner(id=nil?) # Verifies that a user owns an object
    if id.nil? 
      id = params[:id].to_i
    end
    
     if session[:user].nil?
        redirect_to_home
     else
       if !session[:user].id.to_s.eql?(id) && !session[:user].admin
         redirect_to_home      
       end
     end
     
  end 
  
  
  def newpass( len ) # generates a new random password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def update_tab(ontology, concept)  #updates the 'history' tab with the current selected concept
    
    array = session[:ontologies] || []
    found = false
    for item in array
      if item.ontology.eql?(ontology)
        item.concept=concept
        found=true
      end
    end
    
    unless found
      array << History.new(ontology,concept)    
    end

    session[:ontologies]=array
  end

  def remove_tab(ontology_name) # Removes a 'history' tab
    array = session[:ontologies]    
    array.delete(find_tab(ontology_name))        
    session[:ontologies]=array   
  end
  
  def find_tab(ontology_name) # Returns a specific 'history' tab
    array = session[:ontologies]
    for item in array
      if item.ontology.eql?(ontology_name)
        return item        
      end
    end
    return nil
  end
  
end
