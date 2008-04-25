class MappingsController < ApplicationController
 

  # GET /mappings/new
  
  layout 'search'
  
  def index
    @ontologies = DataAccess.getOntologyList() # -- Gets list of ontologies
  end
  
  def count
    @source_counts =[]
    names = ActiveRecord::Base.connection().execute("SELECT count(*) as count,destination_ont from mappings  where source_ont like '#{params[:ontology]}' group by destination_ont")
     names.each_hash(with_table=false) {|x| @source_counts<<x}
    
    @dest_counts = []
    names = ActiveRecord::Base.connection().execute("SELECT count(*) as count,source_ont from mappings  where destination_ont like '#{params[:ontology]}' group by source_ont")
    names.each_hash(with_table=false) {|x| @dest_counts<<x} 
    
    render :partial =>'count'
  end
  
  def show
    #Select *, count(*) as count from mappings where source_ont = 'NCI Thesaurus' and destination_ont = 'Mouse adult gross anatomy' group by destination_id order by count desc limit 100 OFFSET 0 
    
    @mapping_pages = Mapping.paginate_by_sql("Select source_id, count(*) as count from mappings where source_ont = '#{params[:id]}' and destination_ont = '#{params[:target]}' group by source_id order by count desc",:page => params[:page], :per_page => 100,:include=>'users')
    mapping_objects = Mapping.find(:all,:conditions=>["source_ont = '#{params[:id]}' AND destination_ont = '#{params[:target]}' AND source_id IN (?)",@mapping_pages.collect{|item| item[:source_id]}.flatten])
#    @mapping_pages = Mapping.paginate(:page => params[:page], :per_page => 100 ,:conditions=>{:source_ont=>params[:id],:destination_ont=>params[:target]},:order=>'count()',:include=>:user)
    @mappings = {}
    for map in mapping_objects
      puts map.source_id
      if @mappings[map.source_id].nil?
        puts "new mapping"
        @mappings[map.source_id] = [{:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.user_name],:count=>1}]
      else
        puts "Mapping exists"
        @mappings[map.source_id]
        found = false
        for mapping in @mappings[map.source_id]
          puts map.destination_id
          if mapping[:destination_id].eql?(map.destination_id)
            found = true
            mapping[:users]<<map.user.user_name
            mapping[:count]+= 1
            puts "adding to count #{mapping[:count]}"
          end  
        end
        unless found
         @mappings[map.source_id]<< {:source_ont=>map.source_ont,:source_name=>map.source_name,:destination_ont=>map.destination_ont,:destination_name=>map.destination_name,:destination_id=>map.destination_id,:users=>[map.user.user_name],:count=>1}
        end
      end
    end
    @mappings = @mappings.sort {|a,b| b[1].length<=>a[1].length}   #=> [["c", 10], ["a", 20], ["b", 30]]

    render :partial=>'show'
  end
  
  def process_mappings
    mappings = Mapping.find(:all,:conditions=>{:source_name=>nil})
    
    for map in mappings
      begin
      map.source_name = map.source_node.name
      map.destination_name = map.dest_node.name
      map.save
      puts map.inspect
      rescue Exception=>e
        puts e
      end
    end
    
  end
  
  def new
    @mapping = Mapping.new
    @mapping.source_id = params[:source_id]
    @mapping.source_ont = undo_param(params[:ontology])
    @ontologies = DataAccess.getOntologyList() #populates dropdown
    @name = params[:source_name] #used for display
  end

  # POST /mappings
  # POST /mappings.xml
  def create
    #creates mapping
    @mapping = Mapping.new(params[:mapping])
    @mapping.user_id = session[:user].id
    @mapping.save
    
    count = Mapping.count(:conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    CACHE.set("#{@mapping.source_ont.gsub(" ","_")}::#{@mapping.source_id}_MappingCount",count)
    
    
    #repopulates table
    @mappings =  Mapping.find(:all, :conditions=>{:source_ont => @mapping.source_ont, :source_id => @mapping.source_id})
    @ontology = OntologyWrapper.new()
    @ontology.name = @mapping.source_ont
    render :partial =>'mapping_table'
     

  end

end
