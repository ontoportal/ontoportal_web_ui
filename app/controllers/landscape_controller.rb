class LandscapeController < ApplicationController
  layout 'ontology'

  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include_views: false)
    #@submissions = LinkedData::Client::Models::OntologySubmission.all(values: params[:submission])

    # Array with color codes for the pie charts. iterate color_index to change color
    pie_colors_array = ["#2484c1", "#0c6197", "#4daa4b", "#90c469", "#daca61", "#e4a14b", "#e98125", "#cb2121", "#830909", "#923e99", "#ae83d5", "#bf273e", "#ce2aeb", "#bca44a", "#618d1b", "#1ee67b", "#b0ec44", "#a4a0c9", "#322849", "#86f71a", "#d1c87f", "#7d9058", "#44b9b0", "#7c37c0", "#cc9fb1", "#e65414", "#8b6834", "#248838"];
    color_index = 0

    # A hash with the language label and the number of time it appears in sub.naturalLanguage
    groups_hash = {}
    natural_language_hash = {}
    licenseProperty_hash = {}
    prefLabelProperty_hash = {}
    synonymProperty_hash = {}
    definitionProperty_hash = {}
    authorProperty_hash = {}

    people_count_hash = {}

    @metrics_average = [{:attr => "numberOfClasses", :label => "Number of classes", :array => []},
                        {:attr => "numberOfIndividuals", :label => "Number of individuals", :array => []},
                        {:attr => "numberOfProperties", :label => "Number of properties", :array => []},
                        {:attr => "maxDepth", :label => "Max depth", :array => []},
                        {:attr => "maxChildCount", :label => "Max child count", :array => []},
                        {:attr => "averageChildCount", :label => "Average child count", :array => []},
                        {:attr => "classesWithOneChild", :label => "Classes with one child", :array => []},
                        {:attr => "classesWithMoreThan25Children", :label => "Classes with more than 25 children", :array => []},
                        {:attr => "classesWithNoDefinition", :label => "Classes with no definition	", :array => []},
                        {:attr => "numberOfAxioms", :label => "Number of axioms (triples)", :array => []}]

    ontologyFormatsCount = {"OWL" => 0, "SKOS" => 0, "UMLS" => 0, "OBO" => 0}

    # Iterate ontologies to get the submissions with all metadata
    @ontologies.each do |ont|
      sub = ont.explore.latest_submission

      if !sub.nil?

        # Get hash of natural language use
        if !sub.naturalLanguage.nil? && !sub.naturalLanguage.empty?
          sub.naturalLanguage.each do |sub_lang|
            # replace lexvo URI by lexvo prefix
            if sub_lang.start_with?("http://lexvo.org/id/iso639-3/")
              sub_lang = sub_lang.sub("http://lexvo.org/id/iso639-3/", "lexvo:")
            end
            # If lang already in hash then we increment the count of the lang in the hash
            if natural_language_hash.has_key?(sub_lang.to_s)
              natural_language_hash[sub_lang.to_s] = natural_language_hash[sub_lang.to_s] + 1
            else
              natural_language_hash[sub_lang.to_s] = 1
            end
          end
        end

        # Get the prefLabelProperty used for OWL properties in a hash
        if sub.hasOntologyLanguage.eql?("OWL")
          licenseProperty_hash = get_used_properties(sub.hasLicense, nil, licenseProperty_hash)

          prefLabelProperty_hash = get_used_properties(sub.prefLabelProperty, "http://www.w3.org/2004/02/skos/core#prefLabel", prefLabelProperty_hash)

          synonymProperty_hash = get_used_properties(sub.synonymProperty, "http://www.w3.org/2004/02/skos/core#altLabel", synonymProperty_hash)

          definitionProperty_hash = get_used_properties(sub.definitionProperty, "http://www.w3.org/2004/02/skos/core#definition", definitionProperty_hash)

          authorProperty_hash = get_used_properties(sub.authorProperty, "http://purl.org/dc/elements/1.1/creator", authorProperty_hash)
        end

        get_metrics_for_average(sub)

        # Get number of ontologies for each format (for horizontal bar chart)
        ontologyFormatsCount[sub.hasOntologyLanguage] += 1

        # Count number of ontologies for each group (bar chart)
        ont.explore.groups.each do |group|
          if groups_hash.has_key?(group.acronym.to_s)
            groups_hash[group.acronym.to_s] += 1
          else
            groups_hash[group.acronym.to_s] = 1
          end

        end

        # Get people that are mentioned as ontology actors (contact, contributors, creators, curator) to create a tag cloud
        # hasContributor hasCreator contact(explore,name) curatedBy
        contributors_attr_list = [:hasContributor, :hasCreator]
        contributors_attr_list.each do |contributor|
          contributor_label = sub.send(contributor.to_s).to_s
          if !contributor_label.nil?
            contributors_split = contributor_label.split(",")
            contributors_split.each do |contrib|
              if people_count_hash.has_key?(contrib)
                people_count_hash[contrib] += 1
              else
                people_count_hash[contrib] = 1
              end
            end
          end
        end
      end
    end

    # Add value of metrics to the @metrics_average hash
    @metrics_average.each do |metrics|
      metrics[:average] = (metrics[:array].sum / metrics[:array].size.to_f).round(2)
    end

    # Generate the JSON to put natural languages in the pie chart
    @natural_language_json_pie = []
    # Get the different naturalLanguage of submissions to generate a tag cloud
    @people_count_json_cloud = []
    # Generate the JSON to put natural languages in the pie chart
    @licenseProperty_json_pie = []
    @prefLabelProperty_json_pie = []
    @synonymProperty_json_pie = []
    @definitionProperty_json_pie = []
    @authorProperty_json_pie = []

    # Push the results in hash formatted for the Javascript lib that will be displaying it
    natural_language_hash.each do |lang,no|
      @natural_language_json_pie.push({"label"=>lang.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    color_index = 0
    people_count_hash.each do |people,no|
      colour = "%06x" % (rand * 0xffffff)
      @people_count_json_cloud.push({"text"=>people.to_s,"size"=>no*5, "color"=>colour})
    end

    color_index = 0
    licenseProperty_hash.each do |license,no|
      @licenseProperty_json_pie.push({"label"=>license.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    color_index = 0
    prefLabelProperty_hash.each do |pref_label,no|
      @prefLabelProperty_json_pie.push({"label"=>pref_label.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    color_index = 0
    synonymProperty_hash.each do |synonym,no|
      @synonymProperty_json_pie.push({"label"=>synonym.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    color_index = 0
    definitionProperty_hash.each do |definition,no|
      @definitionProperty_json_pie.push({"label"=>definition.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    color_index = 0
    authorProperty_hash.each do |author,no|
      @authorProperty_json_pie.push({"label"=>author.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    # Format the ontologyFormatsCount hash as the JSON needed to generate the chart
    @ontologyFormatsChartJson = { :labels => ontologyFormatsCount.keys,
        :datasets => [{ :label => "Ontology count", :data => ontologyFormatsCount.values,
                       :backgroundColor => ["#669911", "#119966", "#66A2EB", "#FCCE56"],
                       :hoverBackgroundColor => ["#66A2EB", "#FCCE56", "#669911", "#119966"]}] };

    # Format the groupOntologiesCount hash as the JSON needed to generate the chart
    @groupCountChartJson = { :labels => groups_hash.keys,
                                  :datasets => [{ :label => "Number of ontologies in a group", :data => groups_hash.values,
                                                  :backgroundColor => pie_colors_array,
                                                  :hoverBackgroundColor => pie_colors_array.reverse}] };

    @people_count_json_cloud = @people_count_json_cloud.to_json.html_safe
    @natural_language_json_pie = @natural_language_json_pie.to_json.html_safe
    @licenseProperty_json_pie = @licenseProperty_json_pie.to_json.html_safe

    # used properties pie charts html safe formatting
    @prefLabelProperty_json_pie = @prefLabelProperty_json_pie.to_json.html_safe
    @synonymProperty_json_pie = @synonymProperty_json_pie.to_json.html_safe
    @definitionProperty_json_pie = @definitionProperty_json_pie.to_json.html_safe
    @authorProperty_json_pie = @authorProperty_json_pie.to_json.html_safe
    @ontologyFormatsChartJson = @ontologyFormatsChartJson.to_json.html_safe
    @groupCountChartJson = @groupCountChartJson.to_json.html_safe
  end


  ##
  # Add metrics metadata from the param sub to the @metrics_average var to get the average for each metrics
  def get_metrics_for_average(sub)
    # Adding metrics to their arrays

    @metrics_average.each do |metrics|
      if !sub.send(metrics[:attr]).nil?
        metrics[:array].push(sub.send(metrics[:attr]))
      end
    end
  end

  ##
  # Increment the hash entry for the property used by the submission for the given attribute
  # If null it increments the value for the default_property (for prefLabel prop or synonym prop for example)
  def get_used_properties(attr_value, default_property, property_hash)
    if attr_value.nil? || attr_value.empty?
      # if property null then we increment the default value
      if default_property.nil?
        return property_hash
      end
      attr_value = default_property
    else
      attr_value = attr_value.to_s
    end

    # Replace namespace by prefix (defined in application_controller.rb)
    RESOLVE_NAMESPACE.each do |prefix, namespace|
      if attr_value.start_with?(namespace)
        attr_value = attr_value.sub(namespace, "#{prefix}:")
        break;
      end
    end

    # If attribute value property already in hash then we increment the count of the property in the hash
    if property_hash.has_key?(attr_value)
      property_hash[attr_value] = property_hash[attr_value] + 1
    else
      property_hash[attr_value] = 1
    end
    return property_hash
  end
end
