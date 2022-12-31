class OntologiesMetadataCuratorController < ApplicationController
  include TurboHelper, SubmissionsHelper, ActionView::Helpers::FormHelper
  include SubmissionUpdater
  layout :determine_layout
  before_action :submission_metadata, only: [:result, :edit, :update, :show_metadata_by_ontology]

  def result
    @ontologies_ids = params[:ontology][:ontologyId].drop(1)
    @metadata_sel = params[:search][:metadata].drop(1)
    @show_submissions = !params[:show_submissions].nil?
    @ontologies = []
    @submissions = []

    if @ontologies_ids.nil? || @ontologies_ids.empty?
      @ontologies = LinkedData::Client::Models::Ontology.all
    else
      @ontologies_ids.each do |data|
        @ontologies << LinkedData::Client::Models::Ontology.find_by_acronym(data).first
      end
    end

    display_attribute = @metadata_sel + %w[submissionId]
    @ontologies.each do |ont|
      if @show_submissions
        submissions = ont.explore.submissions({ include: display_attribute.join(',') })
      else
        submissions = [ont.explore.latest_submission({ include: display_attribute.join(',') })]
      end
      submissions.each { |sub| append_submission(ont, sub) }
    end

    respond_to do |format|
      format.html { redirect_to admin_index_path }
      format.turbo_stream { render turbo_stream: [
        replace("selection_metadata_form", partial: "ontologies_metadata_curator/result"),
        replace('edit_metadata_btn') do
          helpers.button_tag("Start bulk edit", onclick: 'showEditForm(event)', class: "btn btn-outline-primary mx-1 w-100")
        end
      ] }
    end
  end

  def show_metadata_by_ontology
    @acronym = params[:ontology]
    inline_save = params[:inline_save] && params[:inline_save].eql?('true')
    display_submission_attributes(@acronym, params[:properties]&.split(','),
                                  submissionId: params[:submission_id],
                                  show_sections: false, inline_save: inline_save)
    render partial: 'submissions/form_content', locals: { id: params[:form_id] || '', acronym: @acronym, submissionId: params[:submission_id] }
  end


  def edit

    if params[:selected_acronyms].nil? ||  params[:selected_metadata].nil?
      render_turbo_stream alert_error(id: 'application_modal_content') {"Select in the table submissions (rows) and metadata properties (columns) to start the bulk edit"}
      return
    end

    @selected_ontologies = params[:selected_acronyms].map { |x| x.split(' / ') }
    @selected_metadata = params[:selected_metadata]
    render partial: "ontologies_metadata_curator/form_edit"
  end

    def update
        @selected_ontologies_to_edit = session[:passed_variable2]
        # Convert metadata that needs to be integer to int
        params[:submission].keys.each_index do |i|
            params[:submission].values[i][:contact] = params[:submission].values[i][:contact].values if !params[:submission].values[i][:contact].nil?
            @metadata.map do |hash|
                if hash["enforce"].include?("integer")
                    if !params[:submission].values[i][hash["attribute"]].nil? && !params[:submission].values[i][hash["attribute"]].eql?("")
                        params[:submission].values[i][hash["attribute"].to_s.to_sym] = Integer(params[:submission].values[i][hash["attribute"].to_s.to_sym])
                    end
                end
                if hash["enforce"].include?("boolean") && !params[:submission].values[i][hash["attribute"]].nil?
                    if params[:submission].values[i][hash["attribute"]].eql?("true")
                        params[:submission].values[i][hash["attribute"].to_s.to_sym] = true
                    elsif params[:submission].values[i][hash["attribute"]].eql?("false")
                        params[:submission].values[i][hash["attribute"].to_s.to_sym] = false
                    else
                        params[:submission][hash["attribute"].to_s.to_sym] = nil
                    end
                end
            end
        end
        if params[:check].keys[0].include? "each"
            params[:submission].keys.each_with_index do |ontology, i|
                onto = ontology[/(.*?)_onto/,1]
                params[:submission].values[i][:ontology] = onto
                update_ontology(onto, metadata_params[i])
            end 
        else
            @selected_ontologies_to_edit.each do |ontology|
                params[:submission].values[0][:ontology] = ontology
                update_ontology(ontology, metadata_params[0])
            end               
        end        

        respond_to do |format| 
            format.turbo_stream { render turbo_stream: turbo_stream.update("edition_metadata_form", partial: "ontologies_metadata_curator/form_edit") }
            format.html { redirect_to admin_index_path, notice: "Post was successfully updated." }   
        end

    end
    
  def append_submission(ontology, submission)
    sub = submission
    return if sub.nil?

    sub.ontology = ontology
    @submissions << sub
  end

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
      { contact: [:name, :email] },
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
    out = []
    params.require(:submission).permit!.tap do |x|
      x.keys.each do |y|
        out << x.require(y).permit(attributes.uniq)
      end
    end
    out
  end
end
