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
    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
    # NCBO-658: Avoid stale cached data from LD client: use project params from 'show' link_to.
    @project.update_from_params(params[:project]) unless params[:project].nil?
    @ontologies = LinkedData::Client::Models::Ontology.all
    @usedOntologies = @project.ontologyUsed || []
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
      flash[:notice] = 'Project was successfully created'
      # NCBO-658 notes:
      # @project contains the updated data, but project_path() calls the
      # show method and it gets stale cached data from a new call to
      # @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
      #redirect_to project_path(@project.acronym)
      # Using render avoids the stale cached data in the redirect client call.  However,
      # if a user then follows the 'edit' link on the show page, it will likely encounter
      # the stale cached data during the client call in the edit method.
      @usedOntologies = @project.ontologyUsed || []
      render('show')
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    if params['commit'] == 'Cancel'
      redirect_to project_path(params[:id])
      return
    end
    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
    @project.update_from_params(params[:project])
    error_response = @project.update

    if error_response
      @errors = response_errors(error_response)
    else
      flash[:notice] = 'Project was successfully updated'
      # NCBO-658 notes:
      # @project contains the updated data, but project_path() calls the
      # show method and it gets stale cached data from a new call to
      # @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
      #redirect_to project_path(@project.acronym)
      # Using render avoids the stale cached data in the redirect client call.  However,
      # if a user then follows the 'edit' link on the show page, it will likely encounter
      # the stale cached data during the client call in the edit method.
      @usedOntologies = @project.ontologyUsed || []
      render('show')
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy

    # TODO: enable this method
    redirect_to projects_path
    return

    @project = LinkedData::Client::Models::Project.find_by_acronym(params[:id]).first
    @project.destroy  # This does nothing?

    # TODO: validate the destroy worked?
    #if @project.destroyed?
    #if LinkedData::Client::Models::Project.find_by_acronym(params[:id]).nil? or .empty?

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.xml  { head :ok }
    end
  end

end
