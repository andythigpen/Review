class HomeController < ApplicationController
  before_filter :is_user_signed_in
  before_filter :setup_filters

  #FIXME refactor these functions to reduce common code

  def dashboard
  end

  def inbox
    @inbox = Kaminari.paginate_array(@recent_inbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "inbox", 
                     :filter => "inbox", 
                     :size => @recent_inbox.size } }
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
    @inbox = Kaminari.paginate_array(@late).page(params[:page]).per(20)
    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "inbox",
                     :filter => "late", 
                     :size => @late.size } }
    end
  end

  def outbox
    @outbox = Kaminari.paginate_array(@all_outbox).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "outbox", 
                     :size => @all_outbox.size } }
    end
  end

  def drafts
    @outbox = Kaminari.paginate_array(@drafts).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "drafts", 
                     :size => @drafts.size } }
    end
  end

  def accepted
    @outbox = Kaminari.paginate_array(@accepted).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "accepted", 
                     :size => @accepted.size } }
    end
  end

  def rejected
    @outbox = Kaminari.paginate_array(@rejected).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => "outbox",
                     :filter => "rejected", 
                     :size => @rejected.size } }
    end
  end


 protected
    def is_user_signed_in
      if not user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def setup_filters
      @all_inbox = current_user.review_requests
      @all_outbox = current_user.reviews_owned
      @recent_inbox = []
      @due_soon = []
      @late = []
      @drafts = []
      @accepted = []
      @rejected = []

      @all_inbox.each do |r|
        status = r.status_for(current_user)
        if status.nil?
          @recent_inbox.push(r)
          next if r.duedate.nil?
          if r.duedate.to_date.past? 
            @late.push(r)
          elsif (r.duedate.to_date - 2).past? 
            @due_soon.push(r)
          end
        else
          @recent_inbox.push(r) if not (status.updated_at.to_date + 7).past?
        end
      end

      @all_outbox.each do |r|
        changeset = r.changesets.last
        if not changeset or not changeset.submitted
          @drafts.push(r)
        elsif changeset.accepted?
          @accepted.push(r)
        elsif changeset.rejected?
          @rejected.push(r)
        end
      end
    end
end
