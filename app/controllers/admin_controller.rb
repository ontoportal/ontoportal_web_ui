class AdminController < ApplicationController
  
  layout 'ontology'
  
  def index
    unless !session[:user].nil? && session[:user].admin?
      redirect_to :controller => 'login', :action => 'index', :redirect => '/admin'
    end

    @cache = CACHE

    if params[:resetcache]
      begin
        @cache.reset
      rescue
        @status = "There was a problem reseting the cache connection"
        render :partial => 'status'
      end
      
      @status = "Cache connection successfully reset"
      render :partial => 'status'
    end
    
    if params[:clearcache]
      begin
        @cache.flush_all
      rescue
        @status = "There was a problem flushing the cache"
        render :partial => 'status'
      end
      
      @status = "Cache successfully flushed"
      render :partial => 'status'
    end
    
  end
  
end
