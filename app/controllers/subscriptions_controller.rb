class SubscriptionsController < ApplicationController

  def create
    # Try to get the user linked data instance
    user_id = params[:user_id]
    u = LinkedData::Client::Models::User.find(user_id)
    raise Exception if u.nil?
    # Try to get the ontology linked data instance
    ontology_id = params[:ontology_id]
    if ontology_id.start_with? 'http'
      ont = LinkedData::Client::Models::Ontology.find(ontology_id)
    else
      ont = LinkedData::Client::Models::Ontology.find_by_acronym(ontology_id).first
    end
    raise Exception if ont.nil?
    # Is this request to add or remove a subscription?
    subscribed = params[:subbed]  # string (not boolean)
    if subscribed.eql?("true")
      # Already subscribed, so this request must be a delete
      # Note that this routine removes ALL subscriptions for the ontology, regardless of type.
      u.subscription.delete_if {|sub| sub[:ontology].eql?(ont.acronym) }
    else
      # Not subscribed yet, so this request must be for adding subscription
      subscription = {ontology: ont.acronym, notification_type: NOTIFICATION_TYPES[:notes]}
      u.subscription.push(subscription)
    end
    #
    # TODO: DOUBLE CHECK THIS BEGIN/RESCUE BLOCK
    #
    begin
      u.update # this calls with an HTTP PATCH to the user id
      # How do we get success or failure status from u.update?
      #updated_sub = u.valid?
      updated_sub = true
    rescue
      updated_sub = false
    end
    render :json => { :updated_sub => updated_sub, :user_subscriptions => u.subscription }
  end

end
