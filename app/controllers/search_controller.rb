class SearchController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  
  def index
    @ontologies = DataAccess.getActiveOntologies() 
  end
  
  def concept #search for concept for mappings
    @concepts,@pages = DataAccess.getNodeNameContains([params[:ontology]],params[:name],1)    
    @ontology = DataAccess.getLatestOntology(params[:ontology])
    render :partial => 'concepts'    
  end
  
  def concept_preview #get the priview of the concept for mapping
    @ontology = DataAccess.getOntology(params[:ontology])
    @concept = DataAccess.getNode(params[:ontology],params[:id])
    @children = @concept.children
    render :partial =>'concept_preview'
  end
  
  def search # full search
    
    ontologies = params[:search][:ontologies]
    if ontologies.nil? || ontologies.empty?
      render :text=>"<h1 style='color:red'>Please select an ontology</h1>"
      return
    end
    
    if params[:search][:keyword].empty?
        render :text=>"<h1 style='color:red'>Please Enter a Search Term</h1>"
        return
      end
      
      
    
    @keyword = params[:search][:keyword]

    if params[:search][:attributes].nil? || params[:search][:attributes].eql?("0")
      if params[:search][:search_type].eql?("contains")
        @results,@pages = DataAccess.getNodeNameContains(params[:search][:ontologies],params[:search][:keyword],params[:page]||1)

      elsif params[:search][:search_type].eql?("exact")
        @results,@pages = DataAccess.getNodeNameExact(params[:search][:ontologies],params[:search][:keyword],params[:page]||1)


      end 
    end
  
    if params[:search][:attributes].eql?("1")
      if params[:search][:search_type].eql?("contains")
        @results,@pages =  DataAccess.getAttributeValueContains(params[:search][:ontologies],params[:search][:keyword],params[:page]||1)

        
      elsif params[:search][:search_type].eql?("exact")
        @results,@pages = DataAccess.getAttributeValueExact(params[:search][:ontologies],params[:search][:keyword],params[:page]||1)

        
      end 
      
      
  
    end

        puts "----- debug of results-------"
        puts @results.inspect
        puts @pages.inspect
                puts "-------------------------"
#    session[:search]={}
#    session[:search][:results]=@results
#    session[:search][:ontologies]=@ontologies
#    session[:search][:keyword]=@keyword
    
    if params[:page].nil?
      params[:page]=1
    end
    
    respond_to do |format|
      format.html { render :partial =>'results'}
      format.xml  { render :xml => @results.to_xml }
    end
    
    
  end
  
end
