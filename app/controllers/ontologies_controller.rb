
class OntologiesController < ApplicationController
 
  #caches_page :index
  
  helper :concepts  
  layout 'ontology'
  
  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
    
    @notes={} # Gets list of notes for the ontologies
#    for ont in @ontologies
      #gets last note.. not the best way to do this
#      note = MarginNote.find(:first,:conditions=>{:ontology_id => ont.id},:order=>'margin_notes.id desc')
#      unless note.nil?
#        @notes[ont.id]=note
#      end

#    end
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @ontologies.to_xml }
    end
  end
  
  # GET /ontologies/1
  # GET /ontologies/1.xml
  def show
    @ontology = DataAccess.getOntology(params[:id]) # shows the metadata 
    @versions = DataAccess.getOntologyVersions(@ontology.ontologyId)
      if request.xhr? 
        render :action => "show", :layout => false 
      else 
        render :action=>'show'
      end

  end
  
  def update
      params[:ontology][:isReviewed]=1
      params[:ontology][:isFoundry]=0
    
      @errors = validate(params[:ontology],true)
      if @errors.length < 1
        puts("I should be updating")
        @ontology = DataAccess.updateOntology(params[:ontology])      
     
        if @ontology.kind_of?(Hash) && @ontology[:error]        
          flash[:notice]=@ontology[:longMessage]
         redirect_to ontology_path(:id=>params[:ontology][:id])
        else
      
          redirect_to ontology_path(@ontology)
        end
      else
        @ontology = OntologyWrapper.new
        @ontology.from_params(params[:ontology])
        render :action=> 'edit'
      end
  end
  
  
  def edit
    @ontology = DataAccess.getOntology(params[:id])
  end

  # GET /visualize/:ontology
  def visualize
    
   
    
    #Set the ontology we are viewing
    puts " Ontology #{params[:ontology]}"
    @ontology = DataAccess.getOntology(params[:ontology])
    
          
      
      
      #get the top level nodes for the root
      @root = TreeNode.new()
      nodes = @ontology.topLevelNodes
      puts "Inspecting after toplevel nodes called #{nodes.inspect}"
      @root.set_children(nodes)
      #get the initial concept to display
      puts "Nodes Children: #{@root.children.inspect}"
      @concept = DataAccess.getNode(@ontology.id,@root.children.first.id)
   
   puts @concept.inspect
      
        #gets the initial mappings
        @mappings =Mapping.find(:all, :conditions=>{:source_ont => @ontology.id, :source_id => @concept.id})
        #@mappings_from = Mapping.find(:all, :conditions=>{:destination_ont => @concept.ontology_name, :destination_id => @concept.id},:include=>:user)
        #gets the initial margin notes
        @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @ontology.id, :concept_id => @concept.id,:parent_id => nil})
        @margin_note = MarginNote.new
        @margin_note.concept_id = @concept.id
        @margin_note.ontology_id = @ontology.id
        
       # for demo only
       @software=[]
      if @ontology.displayLabel.eql?("Biomedical Resource Ontology")
        @software = NcbcSoftware.find(:all,:conditions=>{:ontology_label=>@concept.id})        
      end
      #------------------
           
  
   
    unless @concept.id.to_s.empty?
    update_tab(@ontology,@concept.id) #update the tab with the current concept
    end
  
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @ontology.to_xml }
    end
  end
  
  def new
    if(params[:id].nil?)
      @ontology = OntologyWrapper.new
    else
      @ontology = DataAccess.getLastestOntology(params[:id])
    end
  end
  
  def create
    params[:ontology][:isCurrent]=1
    params[:ontology][:isReviewed]=1
    params[:ontology][:isFoundry]=0
    params[:ontology][:userId]=session[:user].id
      @errors = validate(params[:ontology])
      if @errors.length < 1
    @ontology = DataAccess.createOntology(params[:ontology])
      if @ontology.kind_of?(Hash) && @ontology[:error]        
        flash[:notice]=@ontology[:longMessage]
         if(params[:ontology][:ontologyId].empty?)
            @ontology = OntologyWrapper.new
          else
            @ontology = DataAccess.getLastestOntology(params[:ontology][:ontologyId])
          end
      else
    
        redirect_to ontology_path(@ontology)
      end
    
  
    else
      if(params[:ontology][:ontologyId].empty?)
        @ontology = OntologyWrapper.new
      else
        @ontology = DataAccess.getLastestOntology(params[:ontology][:ontologyId])
      end
      
    render :action=>'new'
    end
    
  end
  

  def exhibit
      time = Time.now
       puts "Starting Retrieval"
       @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
       puts "Finished in #{Time.now- time}"

       string =""
       string <<"{
           \"items\" : [\n"

       

       for ont in @ontologies
         string <<"{
         \"title\" : \"#{ont.displayLabel}\" , \n
         \"label\": \"#{ont.id}\",  \n
         \"ontologyId\": \"#{ont.ontologyId}\",\n
         \"version\": \"#{ont.versionNumber}\",\n
         \"status\":\"#{ont.versionStatus}\",\n
         \"format\":\"#{ont.format}\"\n
                  "
         
         if ont.eql?(@ontologies.last)
           string << "}"
          else
            string << "} , "
         end
       end

        response.headers['Content-Type'] = "text/html" 
        
       	string<< "]}"
       render :text=> string


   end  
   private 

     def validate(params, isupdate=false)
       errors=[]
       if params[:displayLabel].nil? || params[:displayLabel].length <1
         errors << "Please Enter an Ontology Name"
       end
       if params[:versionNumber].nil? || params[:versionNumber].length <1
         errors << "Please Enter an Ontology Version"
       end
       if params[:dateReleased].nil? || params[:dateReleased].length <1
         errors << "Please Enter the Date Released"
       end
       unless isupdate
         if params[:isRemote].to_i.eql?(0) && (params[:filePath].nil? || params[:filePath].length <1)
           errors << "Please Choose a File"
         end
         if params[:isRemote].to_i.eql?(1) && (params[:urn].nil? || params[:urn].length <1)
           errors << "Please Enter a URL"
         end
       end
        if params[:contactEmail].nil? || params[:contactEmail].length <1 || !params[:contactEmail].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
          errors << "Please Enter the Contact Email"
        end
       return errors

     end
  
end
