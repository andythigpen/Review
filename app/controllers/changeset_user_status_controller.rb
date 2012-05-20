class ChangesetUserStatusController < ApplicationController
  include MailHelper
  before_filter :authenticate_user!
  rescue_from User::NotAuthorized, :with => :user_not_authorized

  def check_authorization
    raise User::NotAuthorized if current_user != @status.user
  end

  def update
    @status = ChangesetUserStatus.find_by_user_id_and_changeset_id(
            current_user.id, params[:changeset_user_status][:changeset_id])
    params[:changeset_user_status][:user_id] = current_user.id
    success = false
    if @status.nil?
      @status = ChangesetUserStatus.new params[:changeset_user_status]
      success = @status.save
    else
      success = @status.update_attributes params[:changeset_user_status]
    end

    respond_to do |format|
      if success
        review = @status.changeset.review_event
        owner = review.owner

        delay = owner.email_settings.owner[:status_change]
        schedule_email(:time_period => delay,
                       :user => owner,
                       :email_method => :status_email,
                       :email_method_args => [@status, current_user, owner],
                       :summary_method => :status_change_summary_email)

        review.reviewers.each do |r|
          next if r == current_user
          delay = r.email_settings.participant[:status_change]
          schedule_email(:time_period => delay,
                         :user => r,
                         :email_method => :status_participant_email,
                         :email_method_args => [@status, current_user, r],
                         :summary_method => :status_change_summary_email)
        end

        format.json { render :json => { :status => "ok" } }
      else
        format.json { render :json => { :status => "error",
                                        :errors => @status.errors } }
      end
    end
  end

  def destroy
    @status = ChangesetUserStatus.find(params[:id])
    check_authorization
    # move the comments to the changeset so that we don't lose them
    @status.comments.each do |c|
      c.commentable = @status.changeset
      c.save
      c.soft_delete
    end
    @status.destroy

    respond_to do |format|
      format.html { redirect_to :back }    
      format.json { render :json => { :status => "ok" } }
    end
  end
end
