class FairScoreController < ApplicationController

  helper FairScoreHelpers

  def details
    not_found if params[:ontology].nil? || params[:ontology].empty?
    ontology = params[:ontology]

    @fair_scores = MultiJson.load(
      Faraday.get("#{$FAIRNESS_URL}/?portal=#{$HOSTNAME.split('.')[0]}&ontologies=#{ontology}").body)["ontologies"][ontology]
    render partial: 'details'
  end
end