class HomeController < ApplicationController
  
  layout 'home'
  
  def index   
  end

  def release
    
  end


  def feedback
    
  end
  def send_feedback    
    Notifier.deliver_feedback(params[:name],params[:email],params[:comment])   
    flash[:notice]="Feedback has been sent"
    redirect_to_home
  end



end
