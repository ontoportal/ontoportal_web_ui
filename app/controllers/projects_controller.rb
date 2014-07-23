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
    projects = LinkedData::Client::Models::Project.find_by_acronym(params[:id])
    if projects.nil? || projects.empty?
      flash[:notice] = flash_error("Project not found: #{h(params[:id])}")
      redirect_to projects_path
      return
    end
    @project = projects.first
    @usedOntologies = @project.ontologyUsed || []
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
    projects = LinkedData::Client::Models::Project.find_by_acronym(params[:id])
    if projects.nil? || projects.empty?
      flash[:notice] = flash_error("Project not found: #{h(params[:id])}")
      redirect_to projects_path
      return
    end
    @project = projects.first
    @usedOntologies = @project.ontologyUsed || []
    @ontologies = LinkedData::Client::Models::Ontology.all
  end

  # POST /projects
  # POST /projects.xml
  def create
    if params['commit'] == 'Cancel'
      redirect_to projects_path
      return
    end
    @project = LinkedData::Client::Models::Project.new(values: params[:project])
    @project.creator = session[:user].id
    @project_saved = @project.save

    if @project_saved.errors
      @errors = response_errors(@project_saved)
    else
      flash[:notice] = 'Project successfully created'
      redirect_to project_path(@project.acronym)
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    if params['commit'] == 'Cancel'
      redirect_to projects_path
      return
    end
    projects = LinkedData::Client::Models::Project.find_by_acronym(params[:id])
    if projects.nil? || projects.empty?
      flash[:notice] = flash_error("Project not found: #{h(params[:id])}")
      redirect_to projects_path
      return
    end
    @project = projects.first
    @project.update_from_params(params[:project])
    error_response = @project.update
    if error_response
      @errors = response_errors(error_response)
    else
      flash[:notice] = 'Project successfully updated'
      redirect_to project_path(@project.acronym)
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    projects = LinkedData::Client::Models::Project.find_by_acronym(params[:id])
    if projects.nil? || projects.empty?
      flash[:notice] = flash_error("Project not found: #{h(params[:id])}")
      redirect_to projects_path
      return
    end
    @project = projects.first
    error_response = @project.delete
    if error_response
      @errors = response_errors(error_response)
      flash[:notice] = "Project delete failed: #{@errors}"
      respond_to do |format|
        format.html { redirect_to projects_path }
        format.xml  { head :internal_server_error }
      end
    else
      flash[:notice] = 'Project successfully deleted'
      respond_to do |format|
        format.html { redirect_to projects_path }
        format.xml  { head :ok }
      end
    end

  end


  private

  def flash_error(msg)
    "<span style='color:red;'>#{msg}</span>"
  end


end
