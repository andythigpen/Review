class ReviewEventUserController < ApplicationController
  before_filter :authenticate_user!

  def show
    @review_event_user = ReviewEventUser.find(:first, 
        :conditions => [ "user_id = ? and review_event_id = ?", 
                         params[:user_id], params[:review_event_id] ])

    respond_to do |format|
      #format.html # show.html.erb
      #format.xml  { render :xml => @review_event }
      format.js
    end
  end

  def destroy
    review_event = ReviewEvent.find(params[:review_event_id])
    @review_event_user = review_event.reviewers.find(params[:user_id])
    review_event.reviewers.delete(@review_event_user)

    respond_to do |format|
      #format.html { redirect_to(review_events_user_url) }
      #format.xml  { head :ok }
      format.js
    end
  end

end
