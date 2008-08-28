require 'open-uri'
class AjaxProxyController < ApplicationController
  
  
  def get
    
    page = open(params[:url])
    content =  page.read
    puts content
    render :text => content
    
  end
  
end
