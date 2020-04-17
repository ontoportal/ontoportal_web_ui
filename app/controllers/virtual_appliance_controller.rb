class VirtualApplianceController < ApplicationController
  layout 'ontology'

  def index
    @user = session[:user]

    # Go away and come back if you aren't logged in
    if @user.nil?
      redirect_to :controller => 'login', :action => 'index', :redirect => "/virtual_appliance"
      return
    end

    @virtual_appliance_user = VirtualApplianceUser.where(user_id: @user.id)

    @virtual_appliance_access = false
    if !@virtual_appliance_user.nil? && !@virtual_appliance_user.empty? || @user.admin?
      @virtual_appliance_access = true
    end

    users_with_access = VirtualApplianceUser.all
    @users_with_access = []
    users_with_access.each do |user|
      @users_with_access << LinkedData::Client::Models::User.find(user.user_id)
    end
  end

  def create
    user = LinkedData::Client::Models::User.find_by_username(params[:appliance_user][:user_id]).first

    if user.nil?
      flash[:error] = "Problem adding account <strong>#{params[:appliance_user][:user_id]}</strong>: account does not exist".html_safe
      redirect_to action: 'index' and return
    end

    @new_user = VirtualApplianceUser.where(user_id: user.id)
    if @new_user.nil? || @new_user.empty?
      @new_user = VirtualApplianceUser.new
      @new_user.user_id = user.id
      @new_user.save
    end

    redirect_to :action => 'index'
  end

end
