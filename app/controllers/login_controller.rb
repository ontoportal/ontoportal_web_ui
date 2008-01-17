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




end
