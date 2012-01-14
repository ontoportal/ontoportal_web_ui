class VirtualApplianceController < ApplicationController
  layout 'ontology'

  def index
    @user = session[:user]

    # Go away and come back if you aren't logged in
    if @user.nil?
      redirect_to :controller => 'login', :action => 'index', :redirect => "/virtual_appliance"
      return
    end

    @virtual_appliance_user = VirtualApplianceUser.find_all_by_user_id(@user.id.to_i)

    @virtual_appliance_access = false
    if !@virtual_appliance_user.nil? && !@virtual_appliance_user.empty? || @user.admin?
      @virtual_appliance_access = true
    end
  end

  def create
    @new_user = VirtualApplianceUser.find_all_by_user_id(params[:appliance_user][:user_id])
    @new_user = VirtualApplianceUser.new
    @new_user.user_id = params[:appliance_user][:user_id]
    @new_user.save
    redirect_to :action => 'index'
  end

end
