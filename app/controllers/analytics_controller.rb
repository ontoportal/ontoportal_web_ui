# frozen_string_literal: true

require 'csv'

class AnalyticsController < ApplicationController
  def track
    params = analytic_params
    Analytics.create do |a|
      a.segment = params[:segment]
      a.action = params[:analytics_action]
      a.bp_slice = @subdomain_filter[:active] ? @subdomain_filter[:acronym] : nil
      a.ip = request.remote_ip
      a.user = session[:user].nil? ? nil : session[:user].id
      a.params = params.except(:segment, :analytics_action)
    end
    head :ok
  end

  def search_result_clicked
    clicks = Analytics.where(segment: 'search', action: 'result_clicked').all
    rows = [%w[query position_clicked ontology_clicked higher_rated_ontologies additional_result exact_match concept_id time user bp_slice ip_address]]
    clicks.each do |click|
      next if click.params.empty?

      rows << [
        click.params['query'].delete("\t"),
        click.params['position'],
        click.params['ontology_clicked'],
        click.params['higher_ontologies'].nil? ? '' : click.params['higher_ontologies'].join(';'),
        click.params['additional_result'],
        click.params['exact_match'],
        click.params['concept_id'],
        click.created_at.to_formatted_s,
        click.user.to_s,
        click.bp_slice,
        click.ip
      ]
    end
    respond_with_csv_file(rows, 'search_result_clicked')
  end

  private

  def analytic_params
    params.permit(:segment, :analytics_action, :query, :concept_id, :additional_result, :position,
                  { higher_ontologies: [] }, :ontology_clicked)
  end

  def respond_with_csv_file(rows, filename = 'output')
    output = String.new('')
    rows.each do |row|
      output << row.to_csv.force_encoding('UTF-8')
    end
    send_data output, type: 'text/csv', disposition: "attachment; filename=#{filename}.csv"
  end
end
