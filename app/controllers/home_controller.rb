class HomeController < ApplicationController
  before_filter :is_user_signed_in

  #FIXME refactor these functions to reduce common code

  def dashboard
    # @filter = @filter || "inbox"
    @all_inbox = current_user.current_requests
    @due_soon = @all_inbox.find_all do |r| 
      if r.duedate.nil? or not r.status_for(current_user).nil?
        false
      else
        (r.duedate.to_date - 2).past? and not r.duedate.to_date.past? 
      end
    end
    @late = @all_inbox.find_all do |r| 
      if r.duedate.nil? or not r.status_for(current_user).nil?
        false
      else
        r.duedate.to_date.past? 
      end
    end
    # @inbox = Kaminari.paginate_array(@all_inbox).page(params[:page]).per(5)
    @all_outbox = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                  :order => "updated_at DESC")
    @drafts = @all_outbox.find_all do |r| 
      r.changesets.last.nil? or not r.changesets.last.submitted
    end
    @accepted = @all_outbox.find_all do |r| 
      r.changesets.last and r.changesets.last.accepted?
    end
    @rejected = @all_outbox.find_all do |r| 
      r.changesets.last and r.changesets.last.rejected?
    end
    # @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(5)
  end

  def inbox
    @all_inbox = current_user.current_requests
    @inbox = Kaminari.paginate_array(@all_inbox).page(params[:page]).per(20)

    respond_to do |format|
      # format.js { render :partial => "inbox" }
      format.js { render :partial => "dashboard", 
        :locals => { :template => "inbox", 
                     :filter => "inbox", 
                     :size => @all_inbox.size } }
    end
  end

  def due_soon
    @all_inbox = current_user.current_requests
    @all_inbox = @all_inbox.find_all do |r| 
      if r.duedate.nil? or not r.status_for(current_user).nil?
        false 
      else
        (r.duedate.to_date - 2).past? and not r.duedate.to_date.past?
      end
    end
    @inbox = Kaminari.paginate_array(@all_inbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "inbox",
                     :filter => "due_soon", 
                     :size => @all_inbox.size } }
    end
  end

  def late
    @all_inbox = current_user.current_requests
    @all_inbox = @all_inbox.find_all do |r| 
      if r.duedate.nil? or not r.status_for(current_user).nil?
        false
      else
        r.duedate.to_date.past?
      end
    end
    @inbox = Kaminari.paginate_array(@all_inbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "inbox",
                     :filter => "late", 
                     :size => @all_inbox.size } }
    end
  end

  def outbox
    @all_outbox = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                  :order => "updated_at DESC")
    @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "outbox", 
                     :size => @all_outbox.size } }
    end
  end

  def drafts
    @all_outbox = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                  :order => "updated_at DESC")
    @all_outbox = @all_outbox.find_all do |r| 
      r.changesets.last.nil? or not r.changesets.last.submitted
    end

    @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "drafts", 
                     :size => @all_outbox.size } }
    end
  end

  def accepted
    @all_outbox = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                  :order => "updated_at DESC")
    @all_outbox = @all_outbox.find_all do |r| 
      r.changesets.last and r.changesets.last.accepted?
    end

    @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "accepted", 
                     :size => @all_outbox.size } }
    end
  end

  def rejected
    @all_outbox = ReviewEvent.find_all_by_user_id(current_user.id, 
                                                  :order => "updated_at DESC")
    @all_outbox = @all_outbox.find_all do |r| 
      r.changesets.last and r.changesets.last.rejected?
    end

    @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "rejected", 
                     :size => @all_outbox.size } }
    end
  end


 protected
    def is_user_signed_in
      if not user_signed_in?
        redirect_to new_user_session_path
      end
    end
end
