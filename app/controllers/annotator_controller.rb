class AnnotatorController < ApplicationController
  layout 'ontology'

  def index
    ontologies = NCBO::Annotator.ontologies(:apikey => $API_KEY)
    ontology_ids = []
    ontologies.each {|ont| ontology_ids << ont[:virtualOntologyId]}
    @annotator_ontologies = DataAccess.getFilteredOntologyList(ontology_ids)
  end

  def create
    text = params[:text]
    ontology_ids = params[:ontology_ids]

    annotations = NCBO::Annotator.annotate(text, :apikey => $API_KEY, :ontologiesToKeepInResult => ontology_ids, :withDefaultStopWords => true)

    annotations_hash = {}
    annotations.annotations.each do |annotation|
      annotation[:context][:highlight] = highlight_and_get_context(text, [annotation[:context][:from], annotation[:context][:to]]) unless annotations_hash.key?(annotation[:concept][:localConceptId])
      annotations_hash[annotation[:concept][:localConceptId]] = annotation unless annotations_hash.key?(annotation[:concept][:localConceptId])
    end
    annotations.annotations = annotations_hash.values.sort {|a,b| b[:score] <=> a[:score]}

    ontologies_hash = {}
    annotations.ontologies.each do |ont|
      ontologies_hash[ont[:localOntologyId]] = ont
    end
    annotations.ontologies = ontologies_hash

    render :json => annotations
  end

private

  def highlight_and_get_context(text, position, words_to_keep = 4)
    before = text[0, position[0] - 1].split
    highlight = text[position[0] - 1..position[1] - 1]
    after = text[position[1], text.length].split

    before_words = before.length <= words_to_keep ? before.join(" ") : before[before.length - words_to_keep..before.length].join(" ")
    after_words = after.length <= words_to_keep ? after.join(" ") : after[0, words_to_keep].join(" ")

    space_before = before_words[/^[\.\-=\?,'"]/].nil? ? " " : ""
    space_after = after_words[/^[\.\-=\?,'"]/].nil? ? " " : ""

    "#{before_words}#{space_before}<b>#{highlight}</b>#{space_after}#{after_words}"
  end
end
