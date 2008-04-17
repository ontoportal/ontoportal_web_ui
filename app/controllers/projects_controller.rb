class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml
  
  layout 'home'
  
  def index

    if params[:ontology]
      @projects = Project.find(:all,:conditions=>"uses.ontology = '#{undo_param(params[:ontology])}'",:include=>:uses)
    elsif params[:user]
      @projects = Project.find(:all,:conditions=>{:user_id=>params[:user]})
    else
      @projects = Project.find(:all)
    end
    
    respond_to do |format|
      
      format.html {
        if request.xhr? 
          render :action => "index", :layout => false 
        else 
          render :action=>'index'
        end
        }# index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id],:include=>:uses)
    ontologies = @project.uses.collect{|use| use.ontology}
    reviews = Review.find(:all,:conditions=>["ontology in (?) AND project_id = #{params[:id]}",ontologies],:include=>:ratings)
    @reviews = Hash[*(reviews.map{|rev| [rev.ontology, rev] }.flatten)]
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @ontologies = DataAccess.getOntologyList()
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    @project.user_id = session[:user].id
    unless params[:ontologies].nil?
      for ontology in params[:ontologies].keys
        @project.uses << Use.new(:ontology=>ontology)
      end
    end


    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to :controller=>:reviews, :action=>:new, :project=>@project.id}
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

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        @ontologies = DataAccess.getOntologyList()
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
