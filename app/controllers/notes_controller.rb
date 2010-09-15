require 'ostruct'

class NotesController < ApplicationController
  
  layout 'ontology'

  
  # GET /notes
  # GET /notes.xml
  def index
    #@notes = Note.all
    
    @notes = []
    
    rand(20).times {
      @notes_count = 0
      @notes << create_note(1)
    }    

    respond_to do |format|
      format.html { render :template => 'notes/show' }
      format.xml  { render :xml => @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.xml
  def show
    note_id = params[:noteid]
    ontology_id = params[:id]
    
    @note = DataAccess.getNote(ontology_id, note_id, true)
    
    #@note = Note.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end
  
  # GET /notes/virtual/1
  # GET /notes/virtual/1.xml
  def virtual_show
    note_id = params[:noteid]
    concept_id = params[:conceptid]
    ontology_virtual_id = params[:ontology]
    
    @ontology = DataAccess.getLatestOntology(ontology_virtual_id)
    
    @notes_thread_title = "Responses"
    
    if note_id
      notes = DataAccess.getNote(ontology_virtual_id, note_id, true, true)
      if notes.kind_of?(Array)
        @notes = notes[0]
      else
        @notes = notes
      end
    elsif concept_id
      @notes = DataAccess.getNotesForConcept(ontology_virtual_id, concept_id, true, true)
      @note_link = "/notes/virtual/#{@ontology.ontologyId}/?noteid="
      render :partial => 'list', :layout => 'ontology'
      return
    else
      @notes = DataAccess.getNotesForOntology(ontology_virtual_id, true, true)
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
      format.xml  { render :xml => @note }
    end
  end

  def show_single
    note_id = params[:noteid]
    ontology_virtual_id = params[:ontology]
    
    @ontology = DataAccess.getLatestOntology(ontology_virtual_id)
    
    if note_id
      @note = DataAccess.getNote(ontology_virtual_id, note_id, true, true)
    end
    
    render :partial => 'single'
  end
  
  def show_single_list
    note_id = params[:noteid]
    ontology_virtual_id = params[:ontology]
    
    @ontology = DataAccess.getLatestOntology(ontology_virtual_id)
    
    if note_id
      @note = DataAccess.getNote(ontology_virtual_id, note_id, true, true)
    end
    
    @note_link = "/notes/virtual/#{@ontology.ontologyId}/?noteid="
    
    @note_row = { :subject_link => "<a id='row_#{@note.id}' class='notes_list_link' href='#{@note_link}#{@note.id}'>#{@note.subject}</a>",
        :subject => @note.subject,
        :author => Class.new.extend(ApplicationHelper).get_username(@note.author),
        :type => Class.new.extend(NotesHelper).get_note_type_text(@note.type),
        :appliesTo => Class.new.extend(NotesHelper).get_applies_to_link(@note.createdInOntologyVersion, @note.appliesTo['type'], @note.appliesTo['id']) + " (#{@note.appliesTo['type']})",
        :created => time_formatted_from_java(@note.created)
    }

    render :json => @note_row
  end
  
  def show_for_ontology
    @notes = DataAccess.getNotesForOntology(params[:ontology])
    @ontology = DataAccess.getLatestOntology(params[:ontology])
    @notes_for = @ontology.displayLabel
    @notes_for_link = { :controller => 'ontologies', :action => 'virtual', :ontology => params[:ontology] }
    @note_link = "/notes/virtual/#{@ontology.ontologyId}/?noteid="
    render :partial => 'list', :layout => 'ontology'
  end
  
  # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = Note.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = Note.find(params[:id])
  end

  # POST /notes
  # POST /notes.xml
  def create
    @errors = validate(params)
    
    if @errors
      render :text => "Error submitting notes"
      return
    end
    
    @note = DataAccess.createNote(params)
    
    unless @note.nil?
      render :json => @note.to_json
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])
    
    @note.annotated_by = @note.annotated_by.split(%r{,\s*})

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end
  
  def validate(params)
    
  end
  
end
