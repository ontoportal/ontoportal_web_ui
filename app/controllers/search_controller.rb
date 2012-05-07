require 'uri'

class SearchController < ApplicationController

  skip_before_filter :verify_authenticity_token

  layout 'ontology'

  def index
    @search_query = params[:query].nil? ? params[:q] : params[:query]
    @search_query = "" if @search_query.nil?
  end

  def concept #search for concept for mappings
    @ontology = DataAccess.getOntology(params[:ontology])
    @concepts,@pages = DataAccess.getNodeNameContains([@ontology.ontologyId],params[:name],1)
    render :partial => 'concepts'
  end

  def concept_preview #get the priview of the concept for mapping
    @ontology = DataAccess.getOntology(params[:ontology])
    @concept = DataAccess.getNode(params[:ontology],params[:id])
    @children = @concept.children
    render :partial =>'concept_preview'
  end

  def json
    params[:objecttypes] = "class"
    params[:page_size] = 500
    params[:include_props] = 0

    # Temporary hack to figure out which results are exact matches
    exact_results = DataAccess.searchQuery(params[:ontology_ids], params[:query], params[:page], params.merge({:exact_match => true}))
    exact_count = exact_results.results.length
    LOG.add :debug, "*********************************************************************************    #{exact_count}"

    results = DataAccess.searchQuery(params[:ontology_ids], params[:query], params[:page], params)

    # TODO: It would be nice to include a delete command in the iteration above so we don't
    # iterate over the results twice, but it wasn't working and no time to troubleshoot
    filter_private_results(results)

    # Compact results so we only have one per ontology
    compact_results_exact = {}
    compact_results = {}
    results.results.each_with_index do |result, index|
      result['recordTypeFormatted'] = format_record_type(result['recordType'])

      # Hack to add exact match info
      exact_match = index < exact_count

      if exact_match
        if compact_results_exact[result["ontologyId"].to_i].nil?
          compact_results_exact[result["ontologyId"].to_i] = result
        else
          compact_results_exact[result["ontologyId"].to_i]["additional_results"] = result
        end
      else
        if !compact_results_exact[result["ontologyId"].to_i].nil?
          compact_results_exact[result["ontologyId"].to_i]["additional_results"] = result
        else
          compact_results[result["ontologyId"].to_i] = result
        end
      end
    end

    # Rank result sets by ontology weight
    exact_results = OntologyRanker.rank(compact_results_exact.values, {:position => "ontologyId"})
    non_exact_results = OntologyRanker.rank(compact_results.values, {:position => "ontologyId"})

    # Merge result sets and replace original results
    results.results = exact_results.concat non_exact_results

    results.results.slice!(100, results.results.length)
    results.current_page_results = results.results.length

    render :text => results.hash_for_serialization.to_json
  end

  def json_search
    if params[:q].nil?
      render :text => "No search term provided"
      return
    end

    separator = (params[:separator].nil?) ? "~!~" : params[:separator]

    @results,@pages = DataAccess.getNodeNameContains([params[:id]],params[:q], 1, params)

    if params[:id]
      LOG.add :info, 'jump_to_search', request, :virtual_id => params[:id], :search_term => params[:q], :result_count => @results.length
    else
      LOG.add :info, 'jump_to_search', request, :search_term => params[:q], :result_count => @results.length
    end

    response = ""
    for result in @results
      if filter_result?(result)
        @results.delete(result)
        next
      end

      record_type = format_record_type(result[:recordType])
      record_type_value = ""
      for type in record_type
        record_type_value << type[0]
      end

      target_value = result[:preferredName]
      case params[:target]
      when "name" : target_value = result[:preferredName]
      when "shortid" : target_value = result[:conceptIdShort]
      when "uri" : target_value = result[:conceptId]
      else
        target_value = result[:preferredName]
      end

      if params[:id] && params[:id].split(",").length == 1
        response << "#{target_value}|#{result[:conceptIdShort]}|#{record_type}|#{result[:ontologyVersionId]}|#{result[:conceptId]}|#{result[:preferredName]}|#{result[:contents]}|#{CGI.escape(result[:definition])}#{separator}"
      else
        response << "#{target_value}|#{result[:conceptIdShort]}|#{record_type}|#{result[:ontologyVersionId]}|#{result[:conceptId]}|#{result[:preferredName]}|#{result[:contents]}|#{result[:ontologyDisplayLabel]}|#{result[:ontologyId]}|#{CGI.escape(result[:definition])}#{separator}"
      end
    end

    if params[:response].eql?("json")
      response = response.gsub("\"","'")
      response = "#{params[:callback]}({data:\"#{response}\"})"
    end

    #default widget
    @widget="jump"
    if !params[:target].nil?
      #this is the form widget
      @widget="form"
    end

    #dont save it if its a test
    if !request.env['HTTP_REFERER'].nil? && !request.env["HTTP_REFERER"].downcase.include?("bioontology.org")
      widget_log = WidgetLog.find_or_initialize_by_referer_and_widget(request.env["HTTP_REFERER"],@widget)
      if widget_log.id.nil?
        widget_log.count=1
      else
        widget_log.count+=1
      end
      widget_log.save
    end

    render :text => response
  end

  private

  # Filter an array of results based on whether or not the result ontology is private
  def filter_private_results(results)
    return results if session[:user] && session[:user].admin?

    results.results.delete_if { |result|
      # Rescuing 'true' here has the same effect of not showing the result, which is appropriate if we get an error getting ontology metadata
      private = DataAccess.getOntology(result["ontologyId"]).private? rescue true
      if !private
        false
      else
        !(session[:user] && session[:user].acl.include?(result["ontologyId"].to_i))
      end
    }

    results
  end

  # Check if this result should be filtered based on whether or not the result ontology is private
  def filter_result?(result)
    return false if session[:user] && session[:user].admin?

    ontology_id = result["ontologyId"].to_i if result["ontologyId"]
    ontology_id ||= result[:ontologyId]

    # Rescuing 'true' here has the same effect of not showing the result, which is appropriate if we get an error getting ontology metadata
    private = DataAccess.getOntology(ontology_id).private? rescue true

    if !private
      return false
    else
      return !(session[:user] && session[:user].acl.include?(ontology_id))
    end
  end

  def format_record_type(record_type)
    case record_type
      when "apreferredname"
        return "Preferred Name"
      when "bconceptid"
        return "Term ID"
      when "csynonym"
        return "Synonym"
      when "dproperty"
        return "Property"
      else
        return ""
    end
  end

end
