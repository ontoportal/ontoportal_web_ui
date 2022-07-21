class OntologiesMetadataCuratorController < ApplicationController
    layout :determine_layout
    before_action :submission_metadata, only: [:result, :edit, :update]

    def result
        @ontology = LinkedData::Client::Models::Ontology.all.detect {|e| e.acronym == "INRAETHES"}
        @submission = @ontology.explore.latest_submission
        @ontologies_ids = params[:ontology][:ontologyId].drop(1)
        @metadata_sel = params[:search][:metadata].drop(1)
        @ontologies = []
        @submissions = []
        @allOntologies = LinkedData::Client::Models::Ontology.all
        @allsubmissions = LinkedData::Client::Models::OntologySubmission.all
        @ontologies_ids.each do |data|
            @ontologies << @allOntologies.detect {|e| e.acronym == data}
            @submissions << @allsubmissions.detect {|e| e.ontology.acronym == data}
        end
        if @ontologies.empty?
            @ontologies = @allOntologies.sort_by {|e| e.name}
            @submissions = @allsubmissions.sort_by {|e| e.ontology.name}
        end
        respond_to do |format|
            format.html { redirect_to admin_index_path}
            format.turbo_stream { render turbo_stream: turbo_stream.append("selection_metadata_form", partial: "ontologies_metadata_curator/result") }
        end             
    end
    
    def edit
        @selected_ontologies_to_edit = params[:selected_acronyms]
        @selected_metadata_to_edit = params[:selected_metadata]
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym("INRAETHES").first
        #@submission = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology[0].acronym}
        @submission = @ontology.explore.latest_submission
        respond_to do |format|
            format.html { redirect_to admin_index_path}
            format.turbo_stream { render turbo_stream: turbo_stream.replace("edition_metadata_form", partial: "ontologies_metadata_curator/form_edit") }
        end
    end    

    def update
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym("AGROOE").first
        @submission = @ontology.explore.latest_submission
        @submission.update_from_params(metadata_params)
        @ontology.update
        error_response = @submission.update(cache_refresh_all: false)
        redirect_to admin_index_path
    end
    

    private

    def metadata_params
      p = params.require(:submission).permit(:maxChildCount)
      p.to_h
    end
  
end    
