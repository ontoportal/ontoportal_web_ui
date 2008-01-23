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
      @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => params[:ontology_id],:concept_id =>params[:concept_id],:parent_id =>nil})
    elsif !params[:mapping_id].nil?
      @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>params[:mapping_id],:parent_id =>nil})
    end
    
    @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
 
      render :partial =>'show'
 
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
    unless session[:user].nil?
      @margin_note.user_id = session[:user].id
    end
      if @margin_note.save
        flash[:notice] = 'MarginNote was successfully created.'
        
      else
        flash[:notice] = 'Error creating MarginNote'
      end
      
      if !@margin_note.concept_id.nil? && @margin_note.mapping_id.nil?
         @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => @margin_note.ontology_id,:concept_id =>@margin_note.concept_id, :parent_id =>nil})
      elsif !@margin_note.mapping_id.nil?
         @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>@margin_note.mapping_id, :parent_id =>nil})
      end
    
    @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
   # @margin_note.property_name = params[:property]   
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
