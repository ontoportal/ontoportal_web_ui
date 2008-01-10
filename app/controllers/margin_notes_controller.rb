class MarginNotesController < ApplicationController
  # GET /margin_notes
  # GET /margin_notes.xml
  
  layout 'ontology'
  def index
  
  end

  # GET /margin_notes/1
  # GET /margin_notes/1.xml
  def show
    if !params[:concept_id].nil? && params[:property].nil?
      @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => params[:ontology_id],:concept_id =>params[:concept_id],:parent_id =>nil,:property_name =>nil})
    elsif !params[:mapping_id].nil?
      @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>params[:mapping_id],:parent_id =>nil})
      #@name="Map"
    elsif !params[:concept_id].nil? && !params[:property].nil?
      @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => params[:ontology_id],:concept_id =>params[:concept_id],:parent_id =>nil,:property_name =>params[:property]})
    end
    
    @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
    @margin_note.property_name = params[:property]
    @old_value = params[:old]
    @modal = true
    #undo when demo over
    if params[:property].nil?
      render :partial =>'show'
    else
      render :partial =>'proposal'
    end
  end

 
  # GET /margin_notes/1;edit
  # Not Implemented
  def edit
    @margin_note = MarginNote.find(params[:id])
  end

  # POST /margin_notes
  # POST /margin_notes.xml
  def create
    @margin_note = MarginNote.new(params[:margin_note])
      if @margin_note.save
        flash[:notice] = 'MarginNote was successfully created.'
        
      else
        flash[:notice] = 'Error creating MarginNote'
      end
    unless params[:explanation].nil?
      @explanation = MarginNote.new
      @explanation.comment = params[:explanation]
      @explanation.parent_id = @margin_note.id
      @explanation.concept_id = @margin_note.concept_id
      @explanation.property_name = @margin_note.property_name
      @explanation.ontology_id = @margin_note.ontology_id
      @explanation.note_type = 4
      @explanation.subject="Proposal For Change"
      @explanation.save
    end
    
    
      if !@margin_note.concept_id.nil? && @margin_note.mapping_id.nil?
         @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => @margin_note.ontology_id,:concept_id =>@margin_note.concept_id, :parent_id =>nil})
      elsif !@margin_note.mapping_id.nil?
         @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>@margin_note.mapping_id, :parent_id =>nil})
      end
      @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
    @margin_note.property_name = params[:property]   
    render :partial =>'update' 

  end

  # PUT /margin_notes/1
  # PUT /margin_notes/1.xml
  #Not implemented
  def update
   
  end

  # DELETE /margin_notes/1
  # DELETE /margin_notes/1.xml
  #Not Implemented
  def destroy
  end
end
