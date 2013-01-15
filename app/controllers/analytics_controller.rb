require 'csv'

class AnalyticsController < ApplicationController
  def track
    entry = Analytics.new
    entry.segment = params[:segment]
    entry.action = params[:analytics_action]
    entry.slice = @subdomain_filter[:active] ? @subdomain_filter[:acronym] : nil
    entry.ip = request.remote_ip
    entry.user = session[:user].nil? ? nil : session[:user].id
    entry.params = params.except(:segment, :analytics_action, :action, :controller)
    entry.save
    render :text => ""
  end

  def search_result_clicked
    clicks = Analytics.find(:all, :conditions => {:segment => "search", :action => "result_clicked"})
    rows = [["query", "position_clicked", "ontology_clicked", "higher_rated_ontologies", "additional_result", "exact_match", "concept_id", "time", "user", "slice", "ip_address"]]
    clicks.each do |click|
      next if click.params.empty?
      rows << [
        click.params["query"].delete("\t"),
        click.params["position"],
        click.params["ontology_clicked"],
        click.params["higher_ontologies"].nil? ? "" : click.params["higher_ontologies"].join(";"),
        click.params["additional_result"],
        click.params["exact_match"],
        click.params["concept_id"],
        click.created_at,
        click.user,
        click.slice,
        click.ip
      ]
    end

    output = ''
    rows.each do |row|
      output << row.to_csv
    end
    send_data output, :type => 'text/csv', :disposition => 'attachment; filename=search_result_clicked.csv'
  end
end
