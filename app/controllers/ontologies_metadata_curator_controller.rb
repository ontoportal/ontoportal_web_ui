class OntologiesMetadataCuratorController < ApplicationController
    layout :determine_layout
    before_action :submission_metadata, only: [:result, :edit, :update, :show_metadata_by_ontology]

    def result
        @ontologies_ids = params[:ontology][:ontologyId].drop(1)
        @metadata_sel = params[:search][:metadata].drop(1)
        @ontologies = []
        @submissions = []
        @allOntologies = LinkedData::Client::Models::Ontology.all
        @allsubmissions = LinkedData::Client::Models::OntologySubmission.all
        @ontologies_ids.each do |data|
            @ontologies << LinkedData::Client::Models::Ontology.find_by_acronym(data).first
            @submissions << LinkedData::Client::Models::Ontology.find_by_acronym(data).first.explore.latest_submission
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

    def show_metadata_by_ontology
        @acronym = params[:id]
        @submission = LinkedData::Client::Models::Ontology.find_by_acronym(@acronym).first.explore.latest_submission
        @selected_metadata_to_edit = session[:passed_variable1]
    end
    
    def edit
        @selected_ontologies_to_edit = params[:selected_acronyms]
        @selected_metadata_to_edit = params[:selected_metadata]
        session[:passed_variable1] = @selected_metadata_to_edit
        session[:passed_variable2] = @selected_ontologies_to_edit
        @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(@selected_ontologies_to_edit[0]).first
        @submissions = []
        @selected_ontologies_to_edit.each do |data|
            @submissions << LinkedData::Client::Models::Ontology.find_by_acronym(data).first.explore.latest_submission
        end    
        respond_to do |format|
            format.html { redirect_to admin_index_path}
            format.turbo_stream { render turbo_stream: turbo_stream.replace("edition_metadata_form", partial: "ontologies_metadata_curator/form_edit") }
        end 
    end    

    def update
        @selected_ontologies_to_edit = session[:passed_variable2] 
        # Convert metadata that needs to be integer to int
        @metadata.map do |hash|
            if hash["enforce"].include?("integer")
                if !params[:submission][hash["attribute"]].nil? && !params[:submission][hash["attribute"]].eql?("")
                    params[:submission][hash["attribute"].to_s.to_sym] = Integer(params[:submission][hash["attribute"].to_s.to_sym])
                end
            end
            if hash["enforce"].include?("boolean") && !params[:submission][hash["attribute"]].nil?
                if params[:submission][hash["attribute"]].eql?("true")
                    params[:submission][hash["attribute"].to_s.to_sym] = true
                elsif params[:submission][hash["attribute"]].eql?("false")
                    params[:submission][hash["attribute"].to_s.to_sym] = false
                else
                    params[:submission][hash["attribute"].to_s.to_sym] = nil
                end
            end
        end
        @selected_ontologies_to_edit.each do |ontology|
            params[:submission][:ontology] = ontology
            @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(params[:submission][:ontology]).first
            @submission = @ontology.explore.latest_submission
            @submission.update_from_params(metadata_params)
            @submission.update(cache_refresh_all: false)
        end
        puts "ko"
        puts @check
        puts "okey"
    end
    

    private

    def metadata_params
        attributes = [
            :ontology,
            :description,
            :hasOntologyLanguage,
            :prefLabelProperty,
            :synonymProperty,
            :definitionProperty,
            :authorProperty,
            :obsoleteProperty,
            :obsoleteParent,
            :version,
            :status,
            :released,
            :isRemote,
            :pullLocation,
            :filePath,
            { contact:[:name, :email] },
            :homepage,
            :documentation,
            :publication
          ]
          
          @metadata.each do |m|
            
            m_attr = m["attribute"].to_sym
            
            attributes << if m["enforce"].include?("list")
              { m_attr => [] }
            else
              m_attr
            end
          end
          
          p = params.require(:submission).permit(attributes.uniq)
          p.to_h
          end
    
end    
