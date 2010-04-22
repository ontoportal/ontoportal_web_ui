require 'ostruct'

class NotesController < ApplicationController
  # GET /notes
  # GET /notes.xml
  def index
    #@notes = Note.all
    
    @notes = []
    
    rand(20).times {
      @notes_count = 0
      @notes << create_note(1)
    }    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end
  end

 # GET /notes/1
  # GET /notes/1.xml
  def show
    @note = Note.find(params[:id])

    @notes_count = 0
    @notes = create_note(20)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end
  
  def create_note(notes_limit = 20)
    authors = [ "paul", "frank", "henry", "joe", "jessica", "teri", "stephanie", "jill",
                "mark", "matt", "jason", "mario", "elyse", "anna", "jeff", "roger"]
                
    status = ["accepted", "fixed", "won't fix", "closed", "can't reproduce", "not valid"]
    
    note = OpenStruct.new
    note.title = "Suspendisse malesuada arcu mattis lectus porta venenatis"
    note.author = authors[rand(authors.length - 1)]
    note.time = random_time(1)
    note.body = "Lorem ipsum dolor sit amet, consectetur adipiscing elita. Nulla ac enim tincidunt mauris elementum feugiat. Donec sed ante eget purus ultricies imperdiet. Nulla blandit dui sed odio venenatis ut porttitor turpis suscipit. In vitae metus dui. Proin vel libero ipsum. Integer ut mauris odio. Aliquam posuere accumsan risus. Aenean porta molestie erat sed pulvinar. Vestibulum pretium ornare libero, a scelerisque lectus commodo eu. Integer nisl magna, tempor et venenatis ac, vehicula placerat enim. Donec dictum tempor tristique. Proin at hendrerit nulla. Cras in massa vitae dolor porttitor dignissim. Suspendisse malesuada arcu mattis lectus porta venenatis. Duis ut est tellus. Pellentesque condimentum, dolor ac tristique vestibulum, libero augue rhoncus orci, a tempus erat tellus nec mi. Vestibulum a turpis id tortor convallis malesuada. Vestibulum massa turpis, placerat sed hendrerit id, semper eget dui. In eleifend, turpis nec consectetur ultrices, enim quam gravida turpis, vel ornare mauris lorem non libero. Sed eu odio nulla, id sodales diam. Vestibulum sed libero est. Nunc bibendum posuere enim, id pretium mi posuere non. Proin aliquam pellentesque suscipit. Ut tellus sem, ultricies consectetur hendrerit quis, auctor vitae erat. Sed est justo, posuere id porttitor nec, fringilla et risus. Donec in leo at augue condimentum accumsan et sit amet odio. Phasellus laoreet iaculis nisl sit amet vulputate."
    note.responses = []
    note.annotated_by = ""
    note.archived = (rand(16) < 4) ? true : false
    note.hasStatus = status[rand(status.length - 1)]
    note.id = @notes_count
    @notes_count = @notes_count + 1
    
    responses = rand(5)
    if responses > 0 && @notes_count < notes_limit
      responses.times { note.responses << create_note(notes_limit) }
    end
    note
  end

  def random_time(years_back=5)
    year = Time.now.year - rand(years_back) - 1
    month = rand(12) + 1
    day = rand(31) + 1
    Time.local(year, month, day)
  end

   # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = Note.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = Note.find(params[:id])
  end

  # POST /notes
  # POST /notes.xml
  def create
    @note = Note.new(params[:note])
    
    @note.annotated_by = @note.annotated_by.split(%r{,\s*})

    respond_to do |format|
      if @note.save
        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_to(@note) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])
    
    @note.annotated_by = @note.annotated_by.split(%r{,\s*})

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end
end
