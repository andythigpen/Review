class ReviewEventsController < ApplicationController
  # GET /review_events
  # GET /review_events.xml
  def index
    @review_events = ReviewEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @review_events }
    end
  end

  # GET /review_events/1
  # GET /review_events/1.xml
  def show
    @review_event = ReviewEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @review_event }
    end
  end

  # GET /review_events/new
  # GET /review_events/new.xml
  def new
    @review_event = ReviewEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @review_event }
    end
  end

  # GET /review_events/1/edit
  def edit
    @review_event = ReviewEvent.find(params[:id])
  end

  # POST /review_events
  # POST /review_events.xml
  def create
    @review_event = ReviewEvent.new(params[:review_event])

    respond_to do |format|
      if @review_event.save
        format.html { redirect_to(@review_event, :notice => 'Review event was successfully created.') }
        format.xml  { render :xml => @review_event, :status => :created, :location => @review_event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @review_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /review_events/1
  # PUT /review_events/1.xml
  def update
    @review_event = ReviewEvent.find(params[:id])

    respond_to do |format|
      if @review_event.update_attributes(params[:review_event])
        format.html { redirect_to(@review_event, :notice => 'Review event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @review_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /review_events/1
  # DELETE /review_events/1.xml
  def destroy
    @review_event = ReviewEvent.find(params[:id])
    @review_event.destroy

    respond_to do |format|
      format.html { redirect_to(review_events_url) }
      format.xml  { head :ok }
    end
  end
end
