require 'uri'

class SearchController < ApplicationController

  skip_before_filter :verify_authenticity_token

  layout 'ontology'

  def index
    @search_query = params[:query].nil? ? params[:q] : params[:query]
    @search_query ||= ""
  end

  def json_search
    if params[:q].nil?
      render :text => "No search class provided"
      return
    end
    check_params_query(params)
    check_params_ontologies(params)  # Filter on ontology_id
    search_page = LinkedData::Client::Models::Class.search(params[:q], params)
    @results = search_page.collection

    response = ""
    obsolete_response = ""
    separator = (params[:separator].nil?) ? "~!~" : params[:separator]
    for result in @results
      # TODO_REV: Format the response with type information, target information
      # record_type = format_record_type(result[:recordType], result[:obsolete])
      record_type = ""

      target_value = result.prefLabel
      case params[:target]
        when "name"
          target_value = result.prefLabel
        when "shortid"
          target_value = result.id
        when "uri"
          target_value = result.id
      end

      json = []
      json << "#{target_value}"
      json << "|#{result.id}"
      json << "|#{record_type}"
      json << "|#{result.explore.ontology.acronym}"
      json << "|#{result.id}" # Duplicated because we used to have shortId and fullId
      json << "|#{result.prefLabel}"
      # json << "|#{result[:contents]}" TODO_REV: Fix contents for search
      json << "|"
      if params[:id] && params[:id].split(",").length == 1
        json << "|#{CGI.escape((result.definition || []).join(". "))}#{separator}"
      else
        json << "|#{result.explore.ontology.name}"
        json << "|#{result.explore.ontology.acronym}"
        json << "|#{CGI.escape((result.definition || []).join(". "))}#{separator}"
      end

      # Obsolete results go at the end
      if result.obsolete?
        obsolete_response << json.join
      else
        response << json.join
      end
    end

    # Obsolete results merge
    response << obsolete_response

    if params[:response].eql?("json")
      response = response.gsub("\"","'")
      response = "#{params[:callback]}({data:\"#{response}\"})"
    end

    render :text => response
  end


  private

  def check_params_query(params)
    params[:q] = params[:q].strip
    params[:q] = params[:q] + '*' unless params[:q].end_with?("*") # Add wildcard
  end

  def check_params_ontologies(params)
    params[:ontologies] ||= params[:id]
    if params[:ontologies]
      if params[:ontologies].include?(",")
        params[:ontologies] = params[:ontologies].split(",")
      else
        params[:ontologies] = [params[:ontologies]]
      end
      if params[:ontologies].first.to_i > 0
        params[:ontologies].map! {|o| BPIDResolver.id_to_acronym(o)}
      end
      params[:ontologies] = params[:ontologies].join(",")
    end
  end



  # Filters out ontologies from the advanced options that were selected
  # @params [Array] a list of results to filter
  # @params [Hash] hash of parameters from user, can just provide from global params
  # @return [Array] filtered list of results
  def filter_advanced_options(results, params)
    # Remove results due to advanced search options
    advanced_options_results = []
    results.each do |result|
      # The following statements filter results using defaults. They can be overridden with "advanced options"
      # Discard if ontology is not production
      if params[:include_non_production].eql?("false")
        ont = DataAccess.getOntology(result['ontologyId'])
        next unless ont.production? || (!params[:ontology_ids].nil? && params[:ontology_ids].include?(ont.ontologyId.to_s))
      end

      # Discard if the result is an obsolete class
      if params[:include_obsolete].eql?("false")
        next if result['obsolete']
      end

      # Discard if the ontology is a view
      if params[:include_views].eql?("false")
        next if DataAccess.getOntology(result['ontologyId']).view?
      end

      advanced_options_results << result
    end
    advanced_options_results
  end

  # Filter an array of results based on whether or not the result ontology is private
  def filter_private_results(results)
    return results if session[:user] && session[:user].admin?

    results.results.delete_if { |result|
      # Rescuing 'true' here has the same effect of not showing the result,
      # which is appropriate if we get an error getting ontology metadata
      private = DataAccess.getOntology(result["ontologyId"]).private? rescue true
      if !private
        false
      else
        !(session[:user] && session[:user].acl && session[:user].acl.include?(result["ontologyId"].to_i))
      end
    }

    results
  end

  # Check if this result should be filtered based on
  # whether or not the result ontology is private
  def filter_private_result?(result)
    return false if session[:user] && session[:user].admin?

    ontology_id = result["ontologyId"].to_i if result["ontologyId"]
    ontology_id ||= result[:ontologyId]

    # Rescuing 'true' here has the same effect of not showing the result,
    # which is appropriate if we get an error getting ontology metadata
    private = DataAccess.getOntology(ontology_id).private? rescue true

    if !private
      return false
    else
      return !(session[:user] && session[:user].acl.include?(ontology_id.to_i))
    end
  end

  def format_record_type(record_type, obsolete = false)
    case record_type
      when "apreferredname"
        record_text = "Preferred Name"
      when "bconceptid"
        record_text = "Class ID"
      when "csynonym"
        record_text = "Synonym"
      when "dproperty"
        record_text = "Property"
      else
        record_text = ""
    end
    record_text = "Obsolete Class" if obsolete
    record_text
  end

  def set_objecttypes(params)
    if params[:objecttypes].nil? || params[:objecttypes].length == 0
      objecttypes = "class"  # default
    else
      objecttypes = params[:objecttypes]
    end
    return objecttypes
  end

end
