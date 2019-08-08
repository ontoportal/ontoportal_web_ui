class UsersController < ApplicationController
  before_action :unescape_id, only: [:edit, :show, :update]
  before_action :verify_owner, only: [:edit, :show]
  before_action :authorize_admin, only: [:index]

  layout :determine_layout

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
    @user = LinkedData::Client::Models::User.find(session[:user].id)
    @all_ontologies = LinkedData::Client::Models::Ontology.all(ignore_custom_ontologies: true)
    @user_ontologies = @user.customOntology
  end

  # GET /users/new
  def new
    @user = LinkedData::Client::Models::User.new
  end

  # GET /users/1;edit
  def edit
    @user = LinkedData::Client::Models::User.find(params[:id])
    @user ||= LinkedData::Client::Models::User.find_by_username(params[:id]).first

    if (params[:password].eql?("true"))
      @user.validate_password = true
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @errors = validate(user_params)
    @user = LinkedData::Client::Models::User.new(values: user_params)

    if @errors.size < 1
      @user_saved = @user.save
      if @user_saved.errors
        @errors = response_errors(@user_saved)
        # @errors = {acronym: "Username already exists, please use another"} if @user_saved.status == 409
        render :action => "new"
      else
        # Attempt to register user to list
        if params[:user][:register_mail_list]
          Notifier.register_for_announce_list(@user.email).deliver rescue nil
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
    @errors = validate_update(user_params)
    if @errors.size < 1
      @user = LinkedData::Client::Models::User.find(params[:id])
      @user = LinkedData::Client::Models::User.find_by_username(params[:id]).first if @user.nil?

      if params[:user][:password]
        error_response = @user.update(values: {password: params[:user][:password]})
      else
        @user.update_from_params(user_params)
        error_response = @user.update
      end

      if error_response
        @errors = response_errors(error_response)
        # @errors = {acronym: "Username already exists, please use another"} if error_response.status == 409
        render :action => "edit"
      else
        flash[:notice] = 'Account was successfully updated'
        session[:user].update_from_params(user_params)
        redirect_to user_path(@user.username)
      end
    else
      render :action => "edit"
    end
  end

  def custom_ontologies
    @user = LinkedData::Client::Models::User.find(params[:id])
    @user = LinkedData::Client::Models::User.find_by_username(params[:id]).first if @user.nil?

    custom_ontologies = params[:ontology] ? params[:ontology][:ontologyId] : []
    custom_ontologies.reject!(&:blank?)
    @user.update_from_params(customOntology: custom_ontologies)
    error_response = @user.update

    if error_response
      flash[:notice] = 'Error saving Custom Ontologies, please try again'
    else
      updated_user = LinkedData::Client::Models::User.find(@user.id)
      session[:user].update_from_params(customOntology: updated_user.customOntology)
      if updated_user.customOntology.empty?
        flash[:notice] = 'Custom Ontologies were cleared'
      else
        flash[:notice] = 'Custom Ontologies were saved'
      end
    end
    redirect_to user_path(@user.username)
  end

  private

  def user_params
    p = params.require(:user).permit(:firstName, :lastName, :username, :email, :email_confirmation, :password,
                                     :password_confirmation, :register_mail_list)
    p.to_h
  end

  def unescape_id
    params[:id] = CGI.unescape(params[:id])
  end

  def verify_owner
    return if current_user_admin?
    if session[:user].nil? || (!session[:user].id.eql?(params[:id]) && !session[:user].username.eql?(params[:id]))
      redirect_to :controller => 'login', :action => 'index', :redirect => "/accounts/#{params[:id]}"
    end
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
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i)
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
