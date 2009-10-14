# The redirect controller allows for routes-based redirects
# as we move old content to new URL locations.

class RedirectController < ApplicationController
  def index
    if params[:url]
      redirect_to params[:url], :status=>:moved_permanently
      return
    else
      redirect_to "/", :status=>:moved_permanently
    end
  end
end
