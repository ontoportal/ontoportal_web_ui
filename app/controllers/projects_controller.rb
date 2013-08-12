class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml
  
  layout 'ontology'
  
  def index
    @projects = LinkedData::Client::Models::Project.all
    @projects.sort! { |a,b| a.name.downcase <=> b.name.downcase }

    if request.xhr?
      render action: "index", layout: false
    else
      render action: 'index'
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id],:include=>:uses)
    ontologies = @project.uses.collect{|use| use.ontology_id}
    reviews = Review.find(:all,:conditions=>["ontology_id in (?) AND project_id = #{params[:id]}",ontologies],:include=>:ratings)
    @reviews = Hash[*(reviews.map{|rev| [rev.ontology_id, rev] }.flatten)]
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    if session[:user].nil?
      redirect_to :controller => 'login', :action => 'index'
    else
      @project = Project.new
      @ontologies = DataAccess.getOntologyList()
      @ontologies.sort! { |a,b| a.displayLabel.downcase <=> b.displayLabel.downcase }
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @project }
      end
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @ontologies = DataAccess.getOntologyList()
    @usedOntologies = @project.uses.collect{|used| used.ontology_id.to_i}
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    @project.user_id = session[:user].id
    unless params[:ontologies].nil?
      for ontology in params[:ontologies]
        @project.uses << Use.new(:ontology_id=>ontology)
      end
    end


    respond_to do |format|
      if @project.save
        
              #adds project to syndication
               event = EventItem.new
               event.event_type="Project"
               event.event_type_id=@project.id
               event.save
        
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to @project}
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        @ontologies = DataAccess.getOntologyList()
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
    @project.uses = []
    unless params[:ontologies].nil?
      for ontology in params[:ontologies]
        
        @project.uses << Use.new(:ontology_id=>ontology)
      end
    end

    respond_to do |format|
      if @project.update_attributes(params[:project])
        
        
        
        
        flash[:notice] = 'Project was successfully updated.'
         format.html { redirect_to @project}
        format.xml  { head :ok }
      else
        @ontologies = DataAccess.getOntologyList()
         @usedOntologies = @project.uses.collect{|used| used.ontology}
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
