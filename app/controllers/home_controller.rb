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
    "archived"    => "archived",
  }

  @@filters.keys.each do |method|
    define_method method do
      run_filter(method)
    end
  end

  def run_filter(filter, reviews=nil)
    if self.respond_to? "update_#{@@filters[filter]}_counts"
      self.send("update_#{@@filters[filter]}_counts")
    end

    reviews = self.send("update_#{filter}") if reviews.nil?
    reviews = Kaminari.paginate_array(reviews) if reviews.is_a?(Array)

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
      reviews = current_user.submitted_requests.not_archived.search(params[:q])
    elsif template == "outbox"
      reviews = current_user.reviews_owned.not_archived.search(params[:q])
    elsif template == "archived"
      reviews = current_user.reviews_owned.archived.search(params[:q])
    end
    run_filter(template, reviews)
  end

 protected
    def is_user_signed_in
      if not user_signed_in?
        redirect_to new_user_session_path
      end
    end

    def update_inbox_counts
      @all_inbox_count = 0 # disable count for now
      @inbox_count = current_user.recent_requests(7.days.ago).not_archived.
        count("DISTINCT review_events.id")
      @due_soon_count = current_user.requests_due(2.days.from_now).not_archived.
        count("DISTINCT review_events.id")
      @late_count = current_user.late_requests.not_archived.
        count("DISTINCT review_events.id")
    end

    def update_outbox_counts
      @all_outbox_count = 0 # disable count for now
      @outbox_count = current_user.reviews_owned.not_archived.where(
        "review_events.updated_at >= ?", 7.days.ago).count
      @drafts_count= current_user.drafts.not_archived.count
      @accepted_count = 0
      @rejected_count = 0
      @archived_count = 0
    end

    def update_all_inbox
      current_user.submitted_requests.includes(:owner)
    end

    def update_inbox
      current_user.recent_requests(7.days.ago).not_archived.includes(:owner)
    end

    def update_due_soon
      current_user.requests_due(2.days.from_now).not_archived.includes(:owner)
    end

    def update_late
      current_user.late_requests.not_archived.includes(:owner)
    end

    def update_all_outbox
      current_user.reviews_owned.not_archived.includes(:changesets)
    end

    def update_outbox
      current_user.reviews_owned.where("review_events.updated_at >= ?", 
                                       7.days.ago).not_archived
    end

    def update_drafts
      current_user.drafts.not_archived
    end

    def update_accepted
      current_user.reviews_owned.not_archived.select do |r| 
        !r.changesets.last.nil? && r.changesets.last.accepted?
      end
    end

    def update_rejected
      current_user.reviews_owned.not_archived.select do |r| 
        !r.changesets.last.nil? && r.changesets.last.rejected?
      end
    end

    def update_archived
      current_user.reviews_owned.archived.includes(:changesets)
    end
end
