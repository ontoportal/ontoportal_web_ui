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
      render action: "index"
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    if session[:user].nil?
      redirect_to :controller => 'login', :action => 'index'
    else
      @project = LinkedData::Client::Models::Project.new
    end
  end

  # GET /projects/1/edit
  def edit
    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
    @ontologies = LinkedData::Client::Models::Ontology.all
    @usedOntologies = @project.ontologyUsed
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = LinkedData::Client::Models::Project.new(values: params[:project])
    @project.creator = session[:user].id
    @project_saved = @project.save

    if @project_saved.errors
      @errors = response_errors(@project_saved)
    else
      # TODO_REV: Enable syndication
      # Adds project to syndication
      # event = EventItem.new
      # event.event_type="Project"
      # event.event_type_id=@project.id
      # event.save

      flash[:notice] = 'Project was successfully created'
      redirect_to project_path(@project.acronym)
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
    @project.update_from_params(params[:project])
    error_response = @project.update

    if error_response
      @errors = response_errors(error_response)
    else
      flash[:notice] = 'Project was successfully updated'
      redirect_to project_path(@project.acronym)
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
