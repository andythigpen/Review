class ReviewEventsController < ApplicationController
  before_filter :authenticate_user!

  # GET /review_events/1
  # GET /review_events/1.xml
  def show
    @review_event = ReviewEvent.find(params[:id])
    if not params[:changeset].nil?
      @changeset = Changeset.find(params[:changeset])
    else
      @changeset = @review_event.changesets.last
    end
    if not @changeset.nil?
      @status = @changeset.statuses.find_by_user_id(current_user.id)
    end
    if not params[:display].nil?
      @display_type = params[:display]
    elsif not current_user.profile.nil?
      @display_type = current_user.profile.display_type
    end
    # default to split if not yet set in profile
    @display_type = "split" if @display_type.nil?

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

    # for the reviewer_row html partial
    @user_type = :review_event_users
    @parent = @review_event
    @users = @review_event.review_event_users
  end

  # POST /review_events
  # POST /review_events.xml
  def create
    @review_event = ReviewEvent.new(params[:review_event])

    # for the reviewer row html partial
    @user_type = :review_event_users
    @parent = @review_event
    @users = @review_event.review_event_users

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
      begin
        if current_user != @review_event.owner
          @review_event.errors.add(:authorization, "Not authorized to modify this review.")
          success = false
        else
          success = @review_event.update_attributes(params[:review_event])
        end
      rescue ActiveRecord::RecordNotUnique
        @review_event.errors.add(:duplicate, "A user can only be added once to a review.")
      end

      if success
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
      format.json { render :json => { :status => "ok" } }
      format.html { redirect_to(review_events_url) }
      format.xml  { head :ok }
    end
  end

end
