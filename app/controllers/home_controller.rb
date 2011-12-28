class HomeController < ApplicationController
  before_filter :is_user_signed_in
  before_filter :setup_filters

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

    def setup_filters
      @all_inbox = current_user.review_requests
      @all_outbox = current_user.reviews_owned
      @inbox = []
      @due_soon = []
      @late = []
      @outbox = []
      @drafts = []
      @accepted = []
      @rejected = []

      @all_inbox.each do |r|
        status = r.status_for(current_user)
        if status.nil?
          @inbox.push(r)
          next if r.duedate.nil?
          if r.duedate.to_date.past? 
            @late.push(r)
          elsif (r.duedate.to_date - 2).past? 
            @due_soon.push(r)
          end
        else
          @inbox.push(r) if not (status.updated_at.to_date + 7).past?
        end
      end

      @all_outbox.each do |r|
        changeset = r.changesets.last
        already_in_outbox = false

        # show everything in outbox from the past week
        # TODO instead of changeset.updated_at, should it be the latest
        # changeset status updated_at??
        if not changeset.nil? and not (changeset.updated_at.to_date + 7).past?
          @outbox.push(r)
          already_in_outbox = true
        end

        if not changeset or not changeset.submitted
          @drafts.push(r)
          @outbox.push(r) unless already_in_outbox
        elsif changeset.accepted?
          @accepted.push(r)
        elsif changeset.rejected?
          @rejected.push(r)
        else
          @outbox.push(r) unless already_in_outbox
        end
      end
    end
end
