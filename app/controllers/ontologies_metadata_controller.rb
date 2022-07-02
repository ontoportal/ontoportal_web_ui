class OntologiesMetadataController < ApplicationController
    layout :determine_layout



    def result
        @users = LinkedData::Client::Models::User.all
        if session[:user].nil? || !session[:user].admin?
            redirect_to :controller => 'login', :action => 'index', :redirect => '/admin'
        else
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
                format.html { redirect_to admin_index_path, notice: "Greaaat." }
                format.turbo_stream
            end          
        end    
    end
    
    def edit
        #@ontologies = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id])
        #@ontology = @ontologies.first
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
        #@submission = @ontology.explore.latest_submission
        @submission = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology.instance_values["acronym"]}
    end    

    def update
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:id]).first
        @submission = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology.instance_values["acronym"]}
        #@submissions = LinkedData::Client::Models::OntologySubmission.all.detect {|e| e.ontology.acronym == @ontology.instance_values["acronym"]}
        if params['commit'] == 'Cancel'
            redirect_to ontologies_metadata_path
            return
        end
        #parametres = params.require(:submission).permit(:submissionId)
        #@submission.update_from_params(metadata_params)
        @submission.update(metadata_params)
        redirect_to ontologies_metadata_path
    end

    def new
        
    end
    
    private

    def metadata_params
      p = params.require(:submission).permit(:submissionId)
      p.to_h
    end
  
end    
