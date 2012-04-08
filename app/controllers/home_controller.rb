class HomeController < ApplicationController
  before_filter :is_user_signed_in
  before_filter :setup_filters, :only => :dashboard

  # filter name, template
  @@filters = { 
    "inbox"       => "inbox",
    "all_inbox"   => "inbox",
    "due_soon"    => "inbox",
    "late"        => "inbox",
    "outbox"      => "outbox",
    "all_outbox"  => "outbox",
    "drafts"      => "outbox",
    "accepted"    => "outbox",
    "rejected"    => "outbox",
  }

  @@filters.keys.each do |method|
    define_method method do
      run_filter(method)
    end
  end

  def run_filter(filter)
    self.send("update_#{@@filters[filter]}")
    reviews = self.instance_variable_get("@#{filter}")
    pages = Kaminari.paginate_array(reviews).page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => @@filters[filter], 
                     :filters => @@filters,
                     :reviews => pages } }
    end
  end

  def dashboard
  end

 protected
    def is_user_signed_in
      if not user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def update_inbox
      @all_inbox = current_user.submitted_requests
      @inbox = current_user.recent_requests(7.days.ago)
      @due_soon = current_user.requests_due(2.days.from_now)
      @late = current_user.late_requests
    end

    def update_outbox
      @all_outbox = current_user.reviews_owned
      @outbox = current_user.reviews_owned.where("review_events.updated_at >= ?", 7.days.ago)
      @drafts = current_user.drafts
      @accepted = @all_outbox.select {|r| !r.changesets.last.nil? && r.changesets.last.accepted? }
      @rejected = @all_outbox.select {|r| !r.changesets.last.nil? && r.changesets.last.rejected? }
    end

    def setup_filters
      update_inbox
      update_outbox
    end
end
