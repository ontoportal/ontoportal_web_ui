class SearchController < ApplicationController
  
  def index
    @ontologies = DataAccess.getActiveOntologies() 
  end
  
  def concept #search for concept for mappings
    @concepts = DataAccess.getNodeNameContains([params[:ontology]],params[:name])    
    @ontology = DataAccess.getOntology(params[:ontology])
    render :partial => 'concepts'    
  end
  
  def concept_preview #get the priview of the concept for mapping
    @ontology = DataAccess.getOntology(params[:ontology])
    @concept = DataAccess.getNode(params[:ontology],params[:id])
    @children = @concept.children
    render :partial =>'concept_preview'
  end
  
  def search # full search
    
    @results = []
    ontologies = params[:search][:ontologies]
    @ontologies = []
    if ontologies.include?("0")
      #search all ontologies
      @ontologies << DataAccess.getOntologyList()
    else
      for ontology in ontologies
        @ontologies << DataAccess.getOntology(ontology)
      end
    end
    @keyword = params[:search][:keyword]

    if params[:search][:class_name].eql?("1")
      if params[:search][:search_type].eql?("contains")
        @results= @results | DataAccess.getNodeNameContains(params[:search][:ontologies],params[:search][:keyword])
      elsif params[:search][:search_type].eql?("sounds")
        @results= @results | DataAccess.getNodeNameSoundsLike(params[:search][:ontologies],params[:search][:keyword])
      end 
    end
  
    if params[:search][:attributes].eql?("1")
      if params[:search][:search_type].eql?("contains")
        @results= @results | DataAccess.getAttributeValueContains(params[:search][:ontologies],params[:search][:keyword])
      elsif params[:search][:search_type].eql?("sounds")
        @results= @results | DataAccess.getAttributeValueSoundsLike(params[:search][:ontologies],params[:search][:keyword])        
      end 
      
    end

    session[:search]={}
    session[:search][:results]=@results
    session[:search][:ontologies]=@ontologies
    session[:search][:keyword]=@keyword
    
    respond_to do |format|
      format.html { render :partial =>'results'}
      format.xml  { render :xml => @results.to_xml }
    end
    
    
  end
  
end
