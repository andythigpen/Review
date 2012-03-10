class CommentsController < ApplicationController
  before_filter :authenticate_user!

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

        case delay
        when EmailSetting::NONE, nil
          # do nothing
        when EmailSetting::INSTANT
          UserMailer.delay.comment_email(@comment, commentee)
        else
          if not MailSummaryJob.exists?(commentee.id, 
                                        :reply_to_me_summary_email, delay)
            Delayed::Job.enqueue(
              MailSummaryJob.new(commentee.id, 
                                 :reply_to_me_summary_email,
                                 delay), 
              :run_at => EmailSetting.run_date(delay))
          end
        end

        ### send email to participants in review
        review.reviewers.each do |r|
          next if r == commentee  # we already scheduled commentee above
          delay = r.email_settings.participant[:comment_to_anyone]
          case delay
          when EmailSetting::NONE
            # do nothing
          when EmailSetting::INSTANT
            UserMailer.delay.comment_participant_email(@comment, r)
          else
            if not MailSummaryJob.exists?(r.id, 
                                          :comment_to_anyone_summary_email,
                                          delay)
              Delayed::Job.enqueue(
                MailSummaryJob.new(r.id, :comment_to_anyone_summary_email, 
                                   delay),
                 :run_at => EmailSetting.run_date(delay))
            end
          end
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
    level = 0
    level = 1 if @comment.commentable.class == Comment
    if @comment.comments.size > 0
      @comment.update_attribute :user_id, nil
      @comment.update_attribute :content, "[Deleted]"
    else
      destroy_comment(@comment)
    end

    respond_to do |format|
      format.json { render :partial => "shared/comment", 
        :locals => { :comment => @comment, :level => level } }
    end
  end

  protected
    def destroy_comment(comment)
      parent = comment.commentable
      comment.destroy
      if parent and parent.class == Comment and \
        parent.is_deleted? and parent.comments.size == 0
          destroy_comment(parent)
      end
    end

end
