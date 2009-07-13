class ReviewsController < ApplicationController

  # GET /reviews
  # GET /reviews.xml
  
  layout 'ontology'
  
  def index
    @reviews = Review.find(:all,:conditions=>{:ontology_id=>params[:ontology]},:include=>:ratings)
    @ontology=DataAccess.getLatestOntology(params[:ontology])
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
    @review = Review.new(:project_id=>params[:project],:ontology_id=>params[:ontology],:user_id=>session[:user].id)
    @rating_types = RatingType.find(:all)

    if request.xhr?
      render :layout=>false
    end
      

  end

  # GET /reviews/1/edit
  def edit
    @review = Review.find(params[:id])
    @rating_types = RatingType.find(:all)

    if request.xhr?
      render :layout=>false
    end

    
  end

  # POST /reviews
  # POST /reviews.xml
  def create
    
   
        @review = Review.new(params[:review])
        for rating_key in params.keys
          if rating_key.include?("star")
            rating = Rating.new(:rating_type_id=>rating_key.split("_")[1],:value=>params[rating_key])
            @review.ratings << rating
          end            
        end
        @review.user_id = session[:user].id
        @review.save
      
      
                    #adds project to syndication
                     event = EventItem.new
                     event.event_type="Review"
                     event.event_type_id=@review.id
                     event.save

        if request.xhr?
          render :action=>'show', :layout=>false
        else
          redirect_to reviews(:ontology=>review.ontology_id)
        end
  end

  # PUT /reviews/1
  # PUT /reviews/1.xml
  def update
    @review = Review.find(params[:id])
    ratings = Hash[*(@review.ratings.map{|rate| [rate.id.to_i, rate] }.flatten)]
    #puts ratings.inspect
     for rating_key in params.keys
        if rating_key.include?("star")          
          #puts rating_key.split("_")[1].to_i
          ratings[rating_key.split("_")[1].to_i].value=params[rating_key].to_i
          ratings[rating_key.split("_")[1].to_i].save          
        end            
      end
      if @review.update_attributes(params[:review])
        @review.reload
         if request.xhr?
            render :action=>'show', :layout=>false
          else
            redirect_to reviews(:ontology=>review.ontology_id)
          end
      else
        render :action => "edit" 
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
