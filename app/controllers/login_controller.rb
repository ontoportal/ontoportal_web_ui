class LoginController < ApplicationController
  
  # POST /login
  # POST /login.xml
  
  layout 'home'
  def index
    
  end
  
  
  def create
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user] = logged_in_user
        flash[:notice] = "Welcome "+@user.user_name.to_s+"."
        redirect_to_home
      else
        flash[:notice] = "Invalid user name/password combination"
        render :action=>'index'
      end
  end
  
  # DELETE /login
  # DELETE /login.xml
  def destroy
    session[:user] = nil
    flash[:notice] = "Logged out"
    redirect_to_home
  end


  def lost_password
    
  end
  
  def send_pass
    user = User.find(:first,:conditions=>{:email=>params[:email]})
    if user.nil?
      flash[:notice]="No user was created with that email address"
      redirect_to :action=>'lost_password'
    else       
      new_password = newpass(8)
      user.password = new_password
      user.save
      Notifier.deliver_lost_password(user,new_password)
      flash[:notice]="Your Password has been sent to your email address."
      redirect_to_home
    end
  end




end
