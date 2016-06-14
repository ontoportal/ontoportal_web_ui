class LandscapeController < ApplicationController
  layout 'ontology'

  def index
    @ontologies = LinkedData::Client::Models::Ontology.all(include_views: false)
    @submissions = LinkedData::Client::Models::OntologySubmission.all

    # Array with color codes for the pie chart
    pie_colors_array = ["#2484c1", "#0c6197", "#4daa4b", "#90c469", "#daca61", "#e4a14b", "#e98125", "#cb2121", "#830909", "#923e99", "#ae83d5", "#bf273e", "#ce2aeb", "#bca44a", "#618d1b", "#1ee67b", "#b0ec44", "#a4a0c9", "#322849", "#86f71a", "#d1c87f", "#7d9058", "#44b9b0", "#7c37c0", "#cc9fb1", "#e65414", "#8b6834", "#248838"];

    # Generate the JSON to put natural languages in the pie chart
    @natural_language_json_pie = []

    # Get the different naturalLanguage of submissions to generate a tag cloud
    @natural_language_json_cloud = []

    # A hash with the language label and the number of time it appears in sub.naturalLanguage
    natural_language_hash = {}

    color_index = 0
    # Iterate submissions to get the natural languages
    @submissions.each do |sub|
      if !sub.naturalLanguage.nil? && !sub.naturalLanguage.empty?
        sub.naturalLanguage.each do |sub_lang|
          if natural_language_hash.has_key?(sub_lang.to_s)
            natural_language_hash[sub_lang.to_s] = natural_language_hash[sub_lang.to_s] + 1
          else
            natural_language_hash[sub_lang.to_s] = 1
          end
        end
      end
    end

    natural_language_hash.each do |lang,no|
      @natural_language_json_cloud.push({"text"=>lang.to_s,"size"=>10})

      @natural_language_json_pie.push({"label"=>lang.to_s,"value"=>no, "color"=>pie_colors_array[color_index]})
      color_index += 1
    end

    @natural_language_json_cloud = @natural_language_json_cloud.to_json.html_safe
    @natural_language_json_pie = @natural_language_json_pie.to_json.html_safe


  end
end
