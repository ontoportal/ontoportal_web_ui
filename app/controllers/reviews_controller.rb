class ReviewsController < ApplicationController

  # GET /reviews
  # GET /reviews.xml
  
  layout 'home'
  
  def index
    @reviews = Review.find(:all,:conditions=>{:ontology=>undo_param(params[:ontology])},:include=>:ratings)
    @ontology=undo_param(params[:ontology])
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
        @reviews << Review.new(:ontology=> ontology_used.ontology,:project_id=>project.id)
      end
    else    
      @reviews << Review.new(:ontology=>params[:ontology])
    end
    @ontologies = DataAccess.getOntologyList()
    respond_to do |format|
      format.html # new.html.erb
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
        for rating_key in params[key].keys
          if rating_key.include?("ratings")
            puts params[key][rating_key].inspect
            rating = Rating.new(params[key][rating_key])
            review.ratings << rating

          end            
        end
        review.save
      end
    end
      


    respond_to do |format|

        flash[:notice] = 'Review was successfully created.'
        format.html { redirect_to reviews_path(:ontology=>to_param(ontology)) }
        format.xml  { render :xml => @review, :status => :created, :location => @review }
    end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    @review = Review.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        flash[:notice] = 'Review was successfully updated.'
        format.html { redirect_to(@review) }
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
