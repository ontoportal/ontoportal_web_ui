class SubscriptionsController < ApplicationController

  def create
    user_id = params[:user_id]
    ontology_id = params[:ontology_id]
    subbed = params[:subbed]

    if subbed.eql?("true")
      subs = DataAccess.deleteUserSubscriptions(user_id, ontology_id, NOTIFICATION_TYPES[:notes])
    elsif subbed.eql?("false")
      subs = DataAccess.createUserSubscriptions(user_id, ontology_id, NOTIFICATION_TYPES[:notes])
    else
      raise Exception
    end

    updated_sub = true

    render :json => { :updated_sub => updated_sub, :user_subscriptions => subs }
  end

end
