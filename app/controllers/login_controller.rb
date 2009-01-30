class LoginController < ApplicationController
  
  # POST /login
  # POST /login.xml
  
  layout 'ontology'
  def index
    #sets the redirect properties
    unless params[:redirect].nil?
      session[:redirect]={:ontology=>undo_param(params[:redirect]),:tab=>params[:tab]}   
    end
  end
  
  
  def create # logs in a user
#      @user = User.new(params[:user])
#      logged_in_user = @user.try_to_login

      @errors = validate(params[:user])
      if @errors.size <1
        logged_in_user = DataAccess.authenticateUser(params[:user][:username],params[:user][:password])
        if logged_in_user
          session[:user] = logged_in_user
          flash[:notice] = "Welcome "+logged_in_user.username.to_s+"."
          redirect_to_history
        else
          @errors << "Invalid user name/password combination"
          render :action=>'index'
        end
      else
        render :action=>'index'
      end
  end
  
  # DELETE /login
  # DELETE /login.xml
  def destroy #logs out a user
    session[:user] = nil
    flash[:notice] = "Logged out"
    redirect_to_home
  end


  def lost_password
    
  end
  
  def send_pass #sends a new password to the user
    

    
    user = DataAccess.getUserByEmail(params[:user][:email])
    if user.nil?
      flash[:notice]="No user was created with that email address"
      redirect_to :action=>'lost_password'
    else       
      new_password = newpass(8)
      user.password = new_password
      DataAccess.updateUser(user.to_h,user.id)

      Notifier.deliver_lost_password(user,new_password)
      flash[:notice]="Your Password has been sent to your email address."
      redirect_to_home
    end
  end

private 

  def validate(params)
       errors=[]
       
       if params[:username].nil? || params[:username].length <1
         errors << "Please Enter a User Name"
       end
       if params[:password].nil? || params[:password].length <1
         errors << "Please Enter a Password"
       end
     
       return errors

     end


end
