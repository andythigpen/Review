class ChangesetController < ApplicationController
  include MailHelper

  before_filter :authenticate_user!
  cache_sweeper :recent_activity_sweeper
  rescue_from User::NotAuthorized, :with => :user_not_authorized

  def check_authorization
    raise User::NotAuthorized if current_user != @changeset.review_event.owner
  end

  def show
    @changeset = Changeset.find params[:id]
    redirect_to review_event_path(@changeset.review_event) + "?changeset=#{@changeset.id}"
  end

  def create
    @changeset = Changeset.new params[:changeset]
    check_authorization
    if @changeset.name.size == 0
      @changeset.name = "Revision #{@changeset.review_event.changesets.size + 1}"
    end

    respond_to do |format|
      if @changeset.save
        format.json { render :json => { :status => "ok", 
                                        :id => @changeset.id } }
      else 
        format.json { render :json => { :status => "error", 
                                        :errors => @changeset.errors } }
      end
    end
  end

  def update
    @changeset = Changeset.find(params[:id])
    check_authorization

    respond_to do |format|
      if @changeset.update_attributes(params[:changeset])
        if @changeset.submitted
          @changeset.review_event.reviewers.each do |r|
            delay = r.email_settings.participant[:new_changeset]
            schedule_email(:time_period => delay,
                           :user => r,
                           :email_method => :review_request_email,
                           :email_method_args => [r, current_user, @changeset],
                           :summary_method => :new_changeset_summary_email)
          end
        end

        format.json { render :json => { :status => "ok" } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @changeset.errors } }
      end
    end
  end

  def destroy
    @changeset = Changeset.find(params[:id])
    check_authorization
    @changeset.destroy

    respond_to do |format|
      format.js  { render :json => { :status => "ok" } }
    end
  end

  def download
    @changeset = Changeset.find(params[:id])
    @patch = ""
    @changeset.diffs.each do |c|
      @patch += "--- " + c.origin_file + "\n"
      @patch += "+++ " + c.updated_file + "\n"
      @patch += c.contents + "\n"
    end
    send_data @patch, :filename => "changeset_#{@changeset.id}.patch"
  end

end
