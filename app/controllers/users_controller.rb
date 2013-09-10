
class UsersController < ApplicationController
  before_filter :unescape_id, only: [:edit, :show, :update]
  before_filter :verify_owner, only: [:edit, :show]
  before_filter :authorize_admin, only: [:index]

  layout 'ontology'

  # GET /users
  # GET /users.xml
  def index
    @users = LinkedData::Client::Models::User.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = LinkedData::Client::Models::User.find(params[:id])
    @user = LinkedData::Client::Models::User.find_by_username(params[:id]).first if @user.nil?

    # TODO_REV: Enable custom ontology sets
    # @user_ontologies = session[:user_ontologies]
    @user_ontologies ||= {}
  end

  # GET /users/new
  def new
    @user = LinkedData::Client::Models::User.new
  end

  # GET /users/1;edit
  def edit
    @user = LinkedData::Client::Models::User.find(params[:id])
    @user = LinkedData::Client::Models::User.find_by_username(params[:id]).first if @user.nil?

    if (params[:password].eql?("true"))
      @user.validate_password = true
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @errors = validate(params[:user])
    @user = LinkedData::Client::Models::User.new(values: params[:user])

    if @errors.size < 1
      @user_saved = @user.save
      if @user_saved.errors
        @errors = response_errors(@user_saved)
        @errors = {acronym: "Username already exists, please use another"} if @user_saved.status == 409
        render :action => "new"
      else
        # Attempt to register user to list
        if params[:user][:register_mail_list]
          Notifier.deliver_register_for_announce_list(@user.email) rescue nil
        end

        flash[:notice] = 'Account was successfully created'
        session[:user] = LinkedData::Client::Models::User.authenticate(@user.username, @user.password)
        redirect_to_browse
      end
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @errors = validate_update(params[:user])
    if @errors.size < 1
      @user = LinkedData::Client::Models::User.find(params[:id])
      @user = LinkedData::Client::Models::User.find_by_username(params[:id]).first if @user.nil?

      if params[:user][:password]
        error_response = @user.update(values: {password: params[:user][:password]})
      else
        @user.update_from_params(params[:user])
        error_response = @user.update
      end

      if error_response
        @errors = response_errors(error_response)
        @errors = {acronym: "Username already exists, please use another"} if error_response.status == 409
        render :action => "edit"
      else
        flash[:notice] = 'Account was successfully updated'
        session[:user].update_from_params(params[:user])
        redirect_to user_path(CGI.escape(@user.id))
      end
    else
      render :action => "edit"
    end
  end

  def submit_license
    user = session[:user]
    user.ontologylicensetext = params[:ontologylicensetext]
    user.ontologylicense = params[:ontologylicense]
    ontology_id = params[:ontologylicense]

    redirect_location = params[:redirect_location].nil? || params[:redirect_location].empty? ? :back : params[:redirect_location]

    if user.ontologylicensetext.length > 512
      redirect_to :back, :flash => { :error => "License information cannot be longer than 512 characters" }
      return
    end

    if user.ontologylicensetext.length < 2
      redirect_to :back, :flash => { :error => "License information must contain at least two characters" }
      return
    end

    begin
      updated_user = DataAccess.updateUser(user.to_h, user.id)
    rescue Exception => e
      redirect_to :back, :flash => { :error => "There was a problem submitting your license, please try again" }
      return
    end

    DataAccess.removeLatestOntologyFromCache(ontology_id)

    redirect_to redirect_location
  end

  private

  def unescape_id
    params[:id] = CGI.unescape(params[:id])
  end

  def verify_owner
    return if current_user_admin?
    if session[:user].nil? || (!session[:user].id.eql?(params[:id]) && !session[:user].username.eql?(params[:id]))
      redirect_to :controller => 'login', :action => 'index', :redirect => "/accounts/#{params[:id]}"
    end
  end

  def custom_ontologies
    ontologies = params["ontology"] ? params["ontology"]["ontologyId"].collect {|a| a.to_i} : nil

    custom_ontologies = CustomOntologies.find_or_create_by_user_id(session[:user].id)

    if ontologies.nil?
      custom_ontologies.destroy
      session[:user_ontologies] = nil
    else
      custom_ontologies.ontologies = ontologies
      custom_ontologies.save

      session[:user_ontologies] = {} if session[:user_ontologies].nil?
      session[:user_ontologies][:virtual_ids] = custom_ontologies.ontologies
    end

    flash[:notice] = 'Custom Ontologies were saved'
    redirect_to user_path(session[:user].id)
  end

  def get_ontology_list(ont_hash)
    return "" if ont_hash.nil?
    ontologies = []
    ont_hash.each do |ont, checked|
      ontologies << ont if checked.to_i == 1
    end
    ontologies.join(";")
  end

  def validate(params)
    errors=[]
    if !params[:phone].nil? && params[:phone].length > 0
      if  !params[:phone].match(/^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*$/i)
        errors << "Please enter a valid phone number"
      end
    end
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      errors << "Please enter an email address"
    end
    if !params[:email].eql?(params[:email_confirmation])
      errors << "Your Email and Email Confirmation do not match"
    end
    if params[:password].nil? || params[:password].length < 1
      errors << "Please enter a password"
    end
    if !params[:password].eql?(params[:password_confirmation])
      errors << "Your Password and Password Confirmation do not match"
    end
    # verify_recaptcha is a method provided by the recaptcha plugin, returns true or false.
    if ENV['USE_RECAPTCHA'] == 'true'
      if !verify_recaptcha
        errors << "Please fill in the proper text from the supplied image"
      end
    end

    return errors
  end

  def validate_update(params)
    errors=[]
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      errors << "Please enter an email address"
    end
    if !params[:password].eql?(params[:password_confirmation])
      errors << "Your Password and Password Confirmation do not match"
    end

    return errors
  end
end
