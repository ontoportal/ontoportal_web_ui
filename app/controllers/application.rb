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
       puts "User is Nil"
        redirect_to_home
     else
       if !session[:user].id.to_s.eql?(id) && !session[:user].admin
         puts "User is #{session[:user].id} admin is #{session[:user].admin}"
         redirect_to_home      
       end
     end
     
  end 
  
  
  def newpass( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def add_to_tab(ontology, concept)    
    
    array = session[:ontologies] || []
    found = false
    for item in array
      if item.ontology.eql?(ontology.name)
        item = History.new(ontology,concept)
        found=true
      end
    end
    
    unless found
      array << History.new(ontology,concept)    
    end

    session[:ontologies]=array
  end

  def update_tab(ontology,concept)

      array = session[:ontologies] || []
     puts concept.inspect
      for item in array
        if item.ontology.eql?(ontology)
          puts "Ontology being updated"
          item.concept = concept     
        end
      end
      
    session[:ontologies]=array
    
    puts "-----------"
    puts array.inspect
    puts "------------"
    
  end

  def remove_tab(ontology_name)
    array = session[:ontologies]
    for item in array
      if item.ontology.eql?(ontology_name)
        puts "Should be removing"
        array.delete(item)
      end
    end
    
    puts array.inspect
    session[:ontologies]=array
    
  end
  
end
