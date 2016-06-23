class LandscapeController < ApplicationController
  layout 'ontology'

  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include_views: false)
    #@submissions = LinkedData::Client::Models::OntologySubmission.all(values: params[:submission])

    # Array with color codes for the pie chart
    pie_colors_array = ["#2484c1", "#0c6197", "#4daa4b", "#90c469", "#daca61", "#e4a14b", "#e98125", "#cb2121", "#830909", "#923e99", "#ae83d5", "#bf273e", "#ce2aeb", "#bca44a", "#618d1b", "#1ee67b", "#b0ec44", "#a4a0c9", "#322849", "#86f71a", "#d1c87f", "#7d9058", "#44b9b0", "#7c37c0", "#cc9fb1", "#e65414", "#8b6834", "#248838"];

    # A hash with the language label and the number of time it appears in sub.naturalLanguage
    natural_language_hash = {}
    prefLabelProperty_hash = {}
    synonymProperty_hash = {}
    definitionProperty_hash = {}
    authorProperty_hash = {}

    array_metrics_num_classes = []
    array_metrics_number_of_individuals = []
    array_metrics_number_of_properties = []
    array_metrics_max_depth = []
    array_metrics_max_child_count = []
    array_metrics_average_child_count = []
    array_metrics_classes_with_one_child = []
    array_metrics_classes_25_children = []
    array_metrics_classes_no_definition = []
    array_metrics_no_axioms = []

    color_index = 0

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
          prefLabelProperty_hash = get_used_properties(sub.prefLabelProperty, "http://www.w3.org/2004/02/skos/core#prefLabel", prefLabelProperty_hash)

          synonymProperty_hash = get_used_properties(sub.synonymProperty, "http://www.w3.org/2004/02/skos/core#altLabel", synonymProperty_hash)

          definitionProperty_hash = get_used_properties(sub.definitionProperty, "http://www.w3.org/2004/02/skos/core#definition", definitionProperty_hash)

          authorProperty_hash = get_used_properties(sub.authorProperty, "http://purl.org/dc/elements/1.1/creator", authorProperty_hash)
        end

        # Adding metrics to their arrays
        if !sub.numberOfClasses.nil?
          array_metrics_num_classes.push(sub.numberOfClasses)
        end
        if !sub.numberOfIndividuals.nil?
          array_metrics_number_of_individuals.push(sub.numberOfIndividuals)
        end
        if !sub.numberOfProperties.nil?
          array_metrics_number_of_properties.push(sub.numberOfProperties)
        end
        if !sub.maxDepth.nil?
          array_metrics_max_depth.push(sub.maxDepth)
        end
        if !sub.maxChildCount.nil?
          array_metrics_max_child_count.push(sub.maxChildCount)
        end
        if !sub.averageChildCount.nil?
          array_metrics_average_child_count.push(sub.averageChildCount)
        end
        if !sub.classesWithOneChild.nil?
          array_metrics_classes_with_one_child.push(sub.classesWithOneChild)
        end
        if !sub.classesWithMoreThan25Children.nil?
          array_metrics_classes_25_children.push(sub.classesWithMoreThan25Children)
        end
        if !sub.classesWithNoDefinition.nil?
          array_metrics_classes_no_definition.push(sub.classesWithNoDefinition)
        end
        if !sub.numberOfAxioms.nil?
          array_metrics_no_axioms.push(sub.numberOfAxioms)
        end

      end
    end

    @metrics_num_classes_average = get_average(array_metrics_num_classes)
    @metrics_number_of_individuals = get_average(array_metrics_number_of_individuals)
    @number_of_properties = get_average(array_metrics_number_of_properties)
    @metrics_max_depth = get_average(array_metrics_max_depth)
    @metrics_max_child_count = get_average(array_metrics_max_child_count)
    @metrics_average_child_count = get_average(array_metrics_average_child_count)
    @metrics_classes_with_one_child = get_average(array_metrics_classes_with_one_child)
    @metrics_classes_25_children = get_average(array_metrics_classes_25_children)
    @metrics_classes_no_definition = get_average(array_metrics_classes_no_definition)
    @metrics_no_axioms = get_average(array_metrics_no_axioms)


    # Generate the JSON to put natural languages in the pie chart
    @natural_language_json_pie = []
    # Get the different naturalLanguage of submissions to generate a tag cloud
    @natural_language_json_cloud = []
    # Generate the JSON to put natural languages in the pie chart
    @prefLabelProperty_json_pie = []
    @synonymProperty_json_pie = []
    @definitionProperty_json_pie = []
    @authorProperty_json_pie = []

    natural_language_hash.each do |lang,no|
      @natural_language_json_cloud.push({"text"=>lang.to_s,"size"=>no*5, "color"=>pie_colors_array[color_index]})

      @natural_language_json_pie.push({"label"=>lang.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    prefLabelProperty_hash.each do |pref_label,no|
      @prefLabelProperty_json_pie.push({"label"=>pref_label.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    synonymProperty_hash.each do |synonym,no|
      @synonymProperty_json_pie.push({"label"=>synonym.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    definitionProperty_hash.each do |definition,no|
      @definitionProperty_json_pie.push({"label"=>definition.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end
    authorProperty_hash.each do |author,no|
      @authorProperty_json_pie.push({"label"=>author.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    @natural_language_json_cloud = @natural_language_json_cloud.to_json.html_safe
    @natural_language_json_pie = @natural_language_json_pie.to_json.html_safe

    # used properties pie charts html safe formatting
    @prefLabelProperty_json_pie = @prefLabelProperty_json_pie.to_json.html_safe
    @synonymProperty_json_pie = @synonymProperty_json_pie.to_json.html_safe
    @definitionProperty_json_pie = @definitionProperty_json_pie.to_json.html_safe
    @authorProperty_json_pie = @authorProperty_json_pie.to_json.html_safe

  end

  def get_average(integer_array)
    return (integer_array.sum / integer_array.size.to_f).round(2)
  end

  def get_used_properties(attr_value, default_property, property_hash)
    if attr_value.nil? || attr_value.empty?
      # if prefLabelProperty null then we increment the default value
      attr_value = default_property
    else
      attr_value = attr_value.to_s
    end

    # If attribute value property already in hash then we increment the count of the prefLabel in the hash
    if property_hash.has_key?(attr_value)
      property_hash[attr_value] = property_hash[attr_value] + 1
    else
      property_hash[attr_value] = 1
    end
    return property_hash
  end
end
