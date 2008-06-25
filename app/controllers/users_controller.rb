
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
    @user = DataAccess.createUser(params[:user])

    respond_to do |format|
      if @user
        flash[:notice] = 'User was successfully created.'
        session[:user]=@user
        format.html { redirect_to_browse }
        format.xml  { head :created, :location => user_url(@user) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
  
      @user = User.find(params[:id])
  
      respond_to do |format|
        if @user.update_attributes(params[:user])
          flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to edit_user_url(@user) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors.to_xml }
        end
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
end
