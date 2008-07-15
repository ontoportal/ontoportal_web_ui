class MarginNotesController < ApplicationController
  # GET /margin_notes
  # GET /margin_notes.xml
  
  layout 'ontology'
  def index
  
  end

  # GET /margin_notes/1
  # GET /margin_notes/1.xml
  def show
    if !params[:concept_id].nil? && params[:property].nil? #gets concept marginal note
      @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => params[:ontology_id],:concept_id =>params[:concept_id],:parent_id =>nil})
    elsif !params[:mapping_id].nil? # gets Mapping marginal note
      @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>params[:mapping_id],:parent_id =>nil})
    end
    
    #prepopulates marginal note
    @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
 
    render :partial =>'show'
 
  end

 

  # POST /margin_notes
  # POST /margin_notes.xml
  def create
    @margin_note = MarginNote.new(params[:margin_note])
    @key = params[:key] # Timestamp passed from view -- needed to recreate unique form ID

    unless session[:user].nil?
      @margin_note.user_id = session[:user].id
    end
    
      if @margin_note.save               
        flash[:notice] = 'MarginNote was successfully created.'
        
      else
        flash[:notice] = 'Error creating MarginNote'
      end
      
      #repopulates tab
      
      if !@margin_note.concept_id.nil? && @margin_note.mapping_id.nil? # fetches concept marginal notes
         @margin_notes = MarginNote.find(:all, :conditions => {:ontology_id => @margin_note.ontology_id,:concept_id =>@margin_note.concept_id, :parent_id =>nil})
      elsif !@margin_note.mapping_id.nil? # fetches mapping marginal notes
         @margin_notes = MarginNote.find(:all, :conditions => {:mapping_id =>@margin_note.mapping_id, :parent_id =>nil})
      end
    
    #prepopulates new marginal note
    @margin_note = MarginNote.new
    @margin_note.concept_id = params[:concept_id]
    @margin_note.mapping_id = params[:mapping_id]
    
    
    render :partial =>'update' 
    
  end
  
end
