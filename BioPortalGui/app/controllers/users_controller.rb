
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  
  before_filter :authorize_owner, :only=>[:index,:edit,:destroy]
  
  layout 'home'
  
  def index
    
    @users = DataAccess.getUsers

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = DataAccess.getUser(params[:id])
 
  
 
  end

  # GET /users/new
  def new
    @user = UserWrapper.new
  end

  # GET /users/1;edit
  def edit
  @user = DataAccess.getUser(params[:id])
#  @user = User.find(params[:id])
  if(params[:password].eql?("true"))
    @user.validate_password = true
  end
  
  render :action =>'edit'

    
   
  end

  # POST /users
  # POST /users.xml
  def create
#    @user = User.new(params[:user])  
    @errors = validate(params[:user])

    respond_to do |format|
      if @errors.size <1
        @user = DataAccess.createUser(params[:user])
        if @user.kind_of?(Hash) && @user[:error]        
          @errors << @user[:longMessage]
          @user = UserWrapper.new(params[:user])
          format.html { render :action => "new" }
        else
        
        flash[:notice] = 'User was successfully created.'
        session[:user]=@user
        format.html { redirect_to_browse }
        format.xml  { head :created, :location => user_url(@user) }
        end
      else
        @user = UserWrapper.new(params[:user])
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
  
      @user = DataAccess.updateUser(params[:user],params[:id])
      if @user.kind_of?(Hash) && @user[:error]        
        flash[:notice]= @user[:longMessage]
        redirect_to edit_user_path(params[:id])
      else
      flash[:notice] = 'User was successfully updated.'          
      redirect_to user_path(@user.id)
      end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    
  
      @user = User.find(params[:id])
      @user.destroy
  
      respond_to do |format|
        format.html { redirect_to users_url }
        format.xml  { head :ok }
      end
    
  end
  
  
private 

  def validate(params)
    errors=[]
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      errors << "Please Enter an Email Address"
    end
    
    if !params[:phone].nil? && params[:phone].length >0 
      if  !params[:phone].match(/^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*$/i)
        errors << "Please enter a valid phone number"
      end
    end
    if params[:email_confirmation].nil? || params[:email_confirmation].length <1 
      errors << "Please Confirm Your Email Address"
    end
    if !params[:email].eql?(params[:email_confirmation])
      errors << "Your Email and Email Confirmation Do Not Match"
    end
    if params[:username].nil? || params[:username].length <1
      errors << "Please Enter a User Name"
    end
    if params[:password].nil? || params[:password].length <1
      errors << "Please Enter a Password"
    end
    if params[:password_confirmation].nil? || params[:password_confirmation].length <1
      errors << "Please Confirm Your Password"
    end
    if !params[:password].eql?(params[:password_confirmation])
      errors << "Your Password and Password Confirmation Do Not Match"
    end
    
    return errors
    
  end
end
