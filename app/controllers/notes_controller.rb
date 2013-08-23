class NotesController < ApplicationController

  layout 'ontology'


  # GET /notes/1
  # GET /notes/1.xml
  def show
    @notes = LinkedData::Client::Models::Note.get(params[:id], include_threads: true)
    @ontology = (@notes.explore.relatedOntology || []).first

    if request.xhr?
      render :partial => 'thread'
      return
    end

    respond_to do |format|
      format.html { render :template => 'notes/show' }
    end
  end

  # GET /notes/virtual/1
  # GET /notes/virtual/1.xml
  def virtual_show
    note_id = params[:noteid]
    concept_id = params[:conceptid]
    ontology_acronym = params[:ontology]

    @ontology = LinkedData::Client::Models::Ontology.find_by_acronym(ontology_acronym).first

    if note_id
      @notes = LinkedData::Client::Models::Note.get(params[:noteid], include_threads: true)
    elsif concept_id
      @notes = @ontology.explore.single_class(concept_id).explore.notes
      @note_link = "/notes/virtual/#{@ontology.ontologyId}/?noteid="
      render :partial => 'list', :layout => 'ontology'
      return
    else
      @notes = @ontology.explore.notes
      @note_link = "/notes/virtual/#{@ontology.ontologyId}/?noteid="
      render :partial => 'list', :layout => 'ontology'
      return
    end

    if request.xhr?
      render :partial => 'thread'
      return
    end

    respond_to do |format|
      format.html { render :template => 'notes/show' }
    end
  end

  # POST /notes
  # POST /notes.xml
  def create
    if params[:type] && params[:type].eql?("reply")
      note = LinkedData::Client::Models::Reply.new(params)
    elsif params[:type] && params[:type].eql?("ontology")
      params[:relatedOntology] = [params.delete(:parent)]
      note = LinkedData::Client::Models::Note.new(params)
    elsif params[:type] && params[:type].eql?("class")
      params[:relatedClass] = [params.delete(:parent)]
      note = LinkedData::Client::Models::Note.new(params)
    else
      note = LinkedData::Client::Models::Note.new(params)
    end

    new_note = note.save

    if new_note.respond_to?(:errors)
      render :json => new_note.errors, :status => 500
      return
    end

    unless new_note.nil?
      render :json => new_note.to_hash.to_json rescue binding.pry
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    note_ids = params[:noteids].kind_of?(String) ? params[:noteids].split(",") : params[:noteids]

    ontology = DataAccess.getOntology(params[:ontologyid])

    errors = []
    successes = []
    note_ids.each do |note_id|
      begin
        result = DataAccess.deleteNote(note_id, ontology.ontologyId, params[:concept_id])
        raise Exception if !result.nil? && result["errorCode"]
      rescue Exception => e
        errors << note_id
        next
      end
      successes << note_id
    end

    render :json => { :success => successes, :error => errors }
  end

  # POST /notes
  # POST /notes.xml
  def archive
    ontology = DataAccess.getLatestOntology(params[:ontology_virtual_id])

    unless ontology.admin?(session[:user])
      render :json => nil.to_json, :status => 500
      return
    end

    @archive = DataAccess.archiveNote(params)

    unless @archive.nil?
      render :json => @archive.to_json
    end
  end

  def validate(params)
    errors = {}

    if using_captcha? && params[:anonymous].eql?("1")
      if session[:user]
        params["author"] = anonymous_user.id
      else
        valid_recaptcha = verify_recaptcha
        errors[:valid_recaptcha] = false unless valid_recaptcha
      end
    end

    errors
  end

end
