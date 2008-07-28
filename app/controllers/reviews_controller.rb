class ReviewsController < ApplicationController

  # GET /reviews
  # GET /reviews.xml
  
  layout 'home'
  
  def index
    @reviews = Review.find(:all,:conditions=>{:ontology_id=>params[:ontology]},:include=>:ratings)
    @ontology_name=DataAccess.getOntology(params[:ontology]).displayLabel
    respond_to do |format|
      format.html {
        if request.xhr? 
          render :action => "index", :layout => false 
        else 
          render :action=>'index'
        end
        }# index.html.erb
      format.xml  { render :xml => @reviews }
    end
  end

  # GET /reviews/1
  # GET /reviews/1.xml
  def show
    @review = Review.find(params[:id])

    respond_to do |format|

      format.xml  { render :xml => @review }
    end
  end

  # GET /reviews/new
  # GET /reviews/new.xml
  def new
    @reviews =[]
    @rating_types = RatingType.find(:all)
    unless params[:project].nil?
    project = Project.find(params[:project])
      for ontology_used in project.uses
        review = Review.find_or_initialize_by_ontology_id_and_project_id(ontology_used.ontology_id,project.id)
        unless review.id
          review.user_id = session[:user].id
          @reviews << review
        end
      end
    else    
      @reviews << Review.new(:ontology=>params[:ontology],:user_id=>session[:user].id)
    end
    @ontologies = DataAccess.getOntologyList()
    respond_to do |format|


      format.html {
        if @reviews.empty?
          redirect_to project_path(params[:project])
        end                
      }
      format.xml  { render :xml => @review }
    end
  end

  # GET /reviews/1/edit
  def edit
    @review = Review.find(params[:id])
  end

  # POST /reviews
  # POST /reviews.xml
  def create
    
    for key in params.keys
      if key.include?("review")
        review = Review.new(:review=>params[key][:review],:ontology=>undo_param(params[key][:ontology]),:project_id=>params[key][:project_id])
        ontology = review.ontology
        project = review.project_id
        for rating_key in params[key].keys
          if rating_key.include?("ratings")
            puts params[key][rating_key].inspect
            rating = Rating.new(params[key][rating_key])
            review.ratings << rating

          end            
        end
        review.user_id = session[:user].id
        review.save
      end
    end
      


    respond_to do |format|

        flash[:notice] = 'Review was successfully created.'
        format.html { 
          if project.nil?
          redirect_to reviews_path(:ontology=>to_param(ontology)) 
          else
          redirect_to project_path(project)
          end
          }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
    end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    @review = Review.find(params[:id])
    ratings = Hash[*(@review.ratings.map{|rate| [rate.id, rate] }.flatten)]
     for rating_key in params.keys
        if rating_key.include?("ratings")          
          puts rating_key.split("-")[1].to_i
          ratings[rating_key.split("-")[1].to_i].value=params[rating_key].to_i
          ratings[rating_key.split("-")[1].to_i].save          
        end            
      end
    respond_to do |format|
      if @review.update_attributes(params[:review])

        flash[:notice] = 'Review was successfully updated.'
        format.html { redirect_to reviews_path(:ontology=>to_param(@review.ontology)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @review.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.xml
  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.html { redirect_to(reviews_url) }
      format.xml  { head :ok }
    end
  end
end
