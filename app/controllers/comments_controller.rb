class CommentsController < ApplicationController
  before_filter :authenticate_user!
  cache_sweeper :recent_activity_sweeper, :diff_sweeper
  rescue_from User::NotAuthorized, :with => :user_not_authorized

  include MailHelper

  def check_authorization
    raise User::NotAuthorized if current_user != @comment.user
  end

  def create
    @comment = Comment.new params[:comment]

    respond_to do |format|
      if @comment.save
        level = 0
        level = 1 if @comment.commentable.class == Comment

        commentee = nil
        if @comment.commentable.class == Comment
          commentee = @comment.commentable.user
        elsif @comment.commentable.class == Diff
          commentee = @comment.get_review_event().owner
        elsif @comment.commentable.class == ChangesetUserStatus
          commentee = @comment.get_review_event().owner
        end

        ### send email to commentee
        review = @comment.get_review_event
        delay = EmailSetting::NONE
        if commentee == current_user
          # don't email my comment to myself
        elsif commentee == review.owner
          delay = commentee.email_settings.owner[:reply_to_me]
        else
          delay = commentee.email_settings.participant[:reply_to_me]
        end

        schedule_email(:time_period => delay, 
                       :user => commentee, 
                       :email_method => :comment_email, 
                       :email_method_args => [@comment, commentee], 
                       :summary_method => :reply_to_me_summary_email)

        ### send email to participants in review
        review.reviewers.each do |r|
          next if r == commentee    # we already scheduled commentee above
          next if r == current_user # no need to send email to ourself
          delay = r.email_settings.participant[:comment_to_anyone]
          schedule_email(:time_period => delay, 
                         :user => r, 
                         :email_method => :comment_participant_email, 
                         :email_method_args => [@comment, r], 
                         :summary_method => :comment_to_anyone_summary_email)
        end

        format.json { render :partial => "shared/comment", 
            :locals => { :comment => @comment, :level => level } }
      else 
        format.js { render :json => @comment.errors, 
                    :status => :unprocessable_entity }
      end
    end
  end

  def show
    @comment = Comment.find(params[:id])
    changeset = @comment.get_changeset
    redirect_to(changeset_path(changeset) + "#comment_#{@comment.id}")
  end

  def destroy
    @comment = Comment.find(params[:id])
    check_authorization

    level = 0
    level = 1 if @comment.commentable.class == Comment
    @comment.soft_delete

    respond_to do |format|
      format.json { render :partial => "shared/comment", 
        :locals => { :comment => @comment, :level => level } }
    end
  end

end
