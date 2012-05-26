class HomeController < ApplicationController
  before_filter :is_user_signed_in

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
    self.send("update_#{@@filters[filter]}_counts")
    reviews = self.send("update_#{filter}")

    if reviews.is_a?(Array)
      reviews = Kaminari.paginate_array(reviews)
    end
    pages = reviews.page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => @@filters[filter], 
                     :filters => @@filters,
                     :reviews => pages } }
    end
  end

  def dashboard
    update_inbox_counts
    update_outbox_counts
  end

  def search
    reviews = []
    template = @@filters[params[:filter]]
    if template == "inbox"
      reviews = current_user.submitted_requests.search(params[:q])
    elsif template == "outbox"
      reviews = current_user.reviews_owned.search(params[:q])
    end

    if reviews.is_a?(Array)
      reviews = Kaminari.paginate_array(reviews)
    end
    pages = reviews.page(params[:page]).per(20)

    respond_to do |format|
      format.js { render :partial => "dashboard", 
        :locals => { :template => template,
                     :filters => @@filters,
                     :reviews => pages } }
    end
  end

 protected
    def is_user_signed_in
      if not user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def update_inbox_counts
      @all_inbox_count = 0 # disable count for now
      @inbox_count = current_user.recent_requests(7.days.ago).
        count("DISTINCT review_events.id")
      @due_soon_count = current_user.requests_due(2.days.from_now).
        count("DISTINCT review_events.id")
      @late_count = current_user.late_requests.
        count("DISTINCT review_events.id")
    end

    def update_outbox_counts
      @all_outbox_count = 0 # disable count for now
      @outbox_count = current_user.reviews_owned.where(
        "review_events.updated_at >= ?", 7.days.ago).count
      @drafts_count= current_user.drafts.count
      @accepted_count = 0
      @rejected_count = 0
    end

    def update_all_inbox
      current_user.submitted_requests.includes(:owner)
    end

    def update_inbox
      current_user.recent_requests(7.days.ago).includes(:owner)
    end

    def update_due_soon
      current_user.requests_due(2.days.from_now).includes(:owner)
    end

    def update_late
      current_user.late_requests.includes(:owner)
    end

    def update_all_outbox
      current_user.reviews_owned.includes(:changesets)
    end

    def update_outbox
      current_user.reviews_owned.where("review_events.updated_at >= ?", 
                                       7.days.ago)
    end

    def update_drafts
      current_user.drafts
    end

    def update_accepted
      current_user.reviews_owned.select do |r| 
        !r.changesets.last.nil? && r.changesets.last.accepted?
      end
    end

    def update_rejected
      current_user.reviews_owned.select do |r| 
        !r.changesets.last.nil? && r.changesets.last.rejected?
      end
    end
end
