require 'rest-client'
require 'multi_json'

class OntolobridgeController < ApplicationController

  # POST /ontolobridge
  # POST /ontolobridge.xml
  def create
    request_term
  end

  def request_term
    response = {}
    endpoint = "/RequestTerm"
    h_params = {}
    response_raw = nil
    code = 200

    begin
      params.delete("controller")
      params.delete("action")
      params.each { |k, v|
        if v === "on"
          h_params[k] = true
        else
          h_params[k] = v
        end
      }

      response_raw = RestClient.post("#{$ONTOLOBRIDGE_BASE_URL}#{endpoint}", h_params)
      code = response_raw.code
      response.merge!(MultiJson.load(response_raw))
    rescue RestClient::BadRequest => e
      code = 400
      response["error"] = e.message
    rescue Exception => e
      code = 500
      response["error"] = "Problem creating a new term #{endpoint}: #{e.class} - #{e.message}"
    end

    render json: [response, code], status: code
  end

end
