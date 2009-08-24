
class OntologiesController < ApplicationController
 
  #caches_page :index
  
  helper :concepts  
  layout 'ontology'
  
  before_filter :authorize, :only=>[:edit,:update,:create,:new]
  
  # GET /ontologies
  # GET /ontologies.xml
  def index
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
    @categories = DataAccess.getCategories()
    @last_notes= MarginNote.find(:all,:order=>'created_at desc',:limit=>5)    
    @last_mappings = Mapping.find(:all,:order=>'created_at desc',:limit=>5)
  
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
    #Grab Metadata
    @ontology = DataAccess.getOntology(params[:id]) # shows the metadata 
    @categories = DataAccess.getCategories()
    @versions = DataAccess.getOntologyVersions(@ontology.ontologyId)

    @diffs = DataAccess.getDiffs(@ontology.ontologyId)

      note_tag_query = "select concept_id,count(concept_id) as con_count from margin_notes where ontology_id = #{@ontology.ontologyId} group by concept_id order by concept_id"
      @notes = ActiveRecord::Base.connection.select_rows(note_tag_query);
      
      if @notes.size > 100
        note_tag_query = "select concept_id,count(concept_id) as con_count from margin_notes where ontology_id = #{@ontology.ontologyId} group by concept_id order by con_count limit 100 "
        @notes = ActiveRecord::Base.connection.select_rows(note_tag_query);
      end

      mapping_tag_query = "select source_id,count(source_id) as con_count,source_name from mappings where source_ont = #{@ontology.ontologyId} group by source_id order by source_id"            
      @mappings = ActiveRecord::Base.connection.select_rows(mapping_tag_query);
      
      if @mappings.size > 100
        mapping_tag_query = "select source_id,count(source_id) as con_count,source_name from mappings where source_ont = #{@ontology.ontologyId} group by source_id order by con_count limit 100"
        @mappings = ActiveRecord::Base.connection.select_rows(mapping_tag_query);        
      end

    

    #Grab Reviews Tab
    @reviews = Review.find(:all,:conditions=>{:ontology_id=>@ontology.ontologyId},:include=>:ratings)
    
    #Grab projects tab
      @projects = Project.find(:all,:conditions=>"uses.ontology_id = '#{@ontology.ontologyId}'",:include=>:uses)
        render :action=>'show'


  end
  
  def virtual
     time = Time.now
     @ontology = DataAccess.getLatestOntology(params[:ontology])

    @versions = DataAccess.getOntologyVersions(@ontology.ontologyId).sort{|x,y| x.id <=> y.id}

    if @ontology.isRemote.to_i.eql?(1)
      redirect_to "/ontologies/#{@ontology.id}"
      return
    end
    
    if @ontology.statusId.to_i.eql?(3)
      redirect_to "/visualize/#{@ontology.id}"
      return
    else
      for version in @versions
        if version.statusId.to_i.eql?(3)
          redirect_to "/visualize/#{version.id}"
          return
        end
      end
      redirect_to "/ontologies/#{@ontology.id}"
      return
    end
  end
  
  def download_latest
    @ontology = DataAccess.getLatestOntology(params[:id])
    redirect_to "http://rest.bioontology.org/bioportal/ontologies/download/#{@ontology.id}"
  end
  
  def update
      params[:ontology][:isReviewed]=1
      params[:ontology][:isFoundry]=0
    unless !authorize_owner(params[:ontology][:userId].to_i)
      return
    end
    
    
      @errors = validate(params[:ontology],true)
      if @errors.length < 1
        #puts("I should be updating")
        @ontology = DataAccess.updateOntology(params[:ontology],params[:id])      
     
        if @ontology.kind_of?(Hash) && @ontology[:error]        
          flash[:notice]=@ontology[:longMessage]
         redirect_to ontology_path(:id=>params[:id])
        else
          redirect_to ontology_path(@ontology)
        end
      else
        @ontology = OntologyWrapper.new
        @ontology.from_params(params[:ontology])
        @ontology.id = params[:id]
        @categories = DataAccess.getCategories()
        
        render :action=> 'edit'
      end
      
      #puts "I fell through"
  end
  
  
  def edit
    @ontology = DataAccess.getOntology(params[:id])
    

     authorize_owner(@ontology.userId.to_i)  
     @categories = DataAccess.getCategories()
       
  end

  # GET /visualize/:ontology
  def visualize
    
    view = false
    if params[:view]
      view = true
    end
    
    #Set the ontology we are viewing
    if view
      @ontology = DataAccess.getView(params[:ontology])   
    else
      @ontology = DataAccess.getOntology(params[:ontology])   
    end
      #get the top level nodes for the root
      @root = TreeNode.new()
      nodes = @ontology.topLevelNodes(view)
      nodes.sort!{|x,y| x.name.downcase<=>y.name.downcase}
      for node in nodes
        if node.name.downcase.include?("obsolete") || node.name.downcase.include?("deprecated")
          nodes.delete(node)
          nodes.push(node)
        end
      end
      
      @root.set_children(nodes)
      #get the initial concept to display
      @concept = DataAccess.getNode(@ontology.id,@root.children.first.id,view)
   
      
        #gets the initial mappings
        @mappings =Mapping.find(:all, :conditions=>{:source_ont => @ontology.ontologyId, :source_id => @concept.id})
        #@mappings_from = Mapping.find(:all, :conditions=>{:destination_ont => @concept.ontology_name, :destination_id => @concept.id},:include=>:user)
        #builds the margin note tab
         @margin_notes = MarginNote.find(:all,:conditions=>{:ontology_id => @concept.ontology_id, :concept_id => @concept.id,:parent_id =>nil})
         #needed to prepopulate the margin note
         @margin_note = MarginNote.new
         @margin_note.concept_id = @concept.id
         @margin_note.ontology_version_id = @concept.version_id
         @margin_note.ontology_id=@concept.ontology_id
        
       # for demo only
       @software=[]
     if @ontology.ontologyId.to_s.eql?("1104")
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
      @ontology = DataAccess.getLatestOntology(params[:id])
    end
    @categories = DataAccess.getCategories()
    #puts @categories.inspect
  end
  
  
  def new_view
    if(params[:id].nil? || params[:id].to_i < 1)
      @ontology = DataAccess.getOntology(params[:version_id])
    else      
      @ontology = DataAccess.getView(params[:id])
    end
    @categories = DataAccess.getCategories()
    
    
  end
  
  
  def create
    params[:ontology][:isCurrent]=1
    params[:ontology][:isReviewed]=1
    params[:ontology][:isFoundry]=0
    params[:ontology][:isManual]=1
    if (session[:user].admin? && (params[:ontology][:userId].nil? || params[:ontology][:userId].empty?)) || !session[:user].admin?
      params[:ontology][:userId]= session[:user].id
    end
    #puts "File Size: #{params[:ontology][:filePath].size}"
      @errors = validate(params[:ontology])
    if @errors.length < 1
    @ontology = DataAccess.createOntology(params[:ontology])
      if @ontology.kind_of?(Hash) && @ontology[:error]        
        flash[:notice]=@ontology[:longMessage]
         if(params[:ontology][:ontologyId].empty?)
            @ontology = OntologyWrapper.new
          else
            @ontology = DataAccess.getLatestOntology(params[:ontology][:ontologyId])
          end
        render :action=>'new'  
      else
    
      #puts "Ontology Error: #{@ontology.inspect}"
        #adds ontology to syndication
         event = EventItem.new
         event.event_type="Ontology"
         event.event_type_id=@ontology.id
         event.ontology_id=@ontology.ontologyId
         event.save
         flash[:notice]="Thank you for submitting your ontology to BioPortal.
          We will now put your ontology in the queue to be processed.
           Please keep in mind that it may take up to several hours before BioPortal users will be able to explore and search your ontology"
        redirect_to ontology_path(@ontology)
      end
    
  
    else
      if(params[:ontology][:ontologyId].empty?)
        @ontology = OntologyWrapper.new
        @ontology.from_params(params[:ontology])
        @categories = DataAccess.getCategories()
        
      else
        @ontology = DataAccess.getLatestOntology(params[:ontology][:ontologyId])
        @ontology.from_params(params[:ontology])
        @categories = DataAccess.getCategories()
        
      end
      
    render :action=>'new'
    end
    
  end
  

  def exhibit
      time = Time.now
       #puts "Starting Retrieval"
       @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
       #puts "Finished in #{Time.now- time}"

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
         if params[:isRemote].to_i.eql?(0) && params[:filePath].size.to_i > 20000000 && !session[:user].admin?
            errors << "File is too large"
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
