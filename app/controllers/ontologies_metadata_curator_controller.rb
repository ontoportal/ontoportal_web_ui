class OntologiesMetadataCuratorController < ApplicationController
    layout :determine_layout



    def result
        @ontologies_ids = params[:ontology][:ontologyId].drop(1)
        @metadata_sel = params[:search][:metadata].drop(1)
        @ontologies = []
        @submissions = []
        @ontologies_ids.each do |data|
            @ontologies << LinkedData::Client::Models::Ontology.all.detect {|e| e.acronym == data}
            @submissions << LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == data}
        end
        if @ontologies.empty?
            @ontologies = LinkedData::Client::Models::Ontology.all.sort_by {|e| e.name}
            @submissions = LinkedData::Client::Models::OntologySubmission.all.sort_by {|e| e.ontology.name}
        end
        respond_to do |format|
            format.html { redirect_to admin_index_path}
            format.turbo_stream { render turbo_stream: turbo_stream.append("choices", partial: "ontologies_metadata_curator/result") }
        end             
    end
    
    def edit
        @selected_ontologies_to_edit = params[:selected_acronyms]
        @selected_metadata_to_edit = params[:selected_metadata]
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(@selected_ontologies_to_edit[0])
        @submission = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology[0].acronym}
        respond_to do |format|
            format.html { redirect_to admin_index_path}
            format.turbo_stream { render turbo_stream: turbo_stream.replace("editmodal", partial: "ontologies_metadata_curator/form_edit") }
        end
        # @selected_ontologies_edit = @ontologies.where(acronym: params[:ontologies_acronymes])
        #@ontologies = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id])
        #@ontology = @ontologies.first
        #@ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
        #@submission = @ontology.explore.latest_submission
        #@submission = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology.instance_values["acronym"]}
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
      p = params.require(:submission).permit(:submissionId)
      p.to_h
    end
  
end    
