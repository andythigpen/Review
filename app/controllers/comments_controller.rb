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

        review = @comment.get_review_event
        delay = EmailSetting::NONE
        if commentee == review.owner
          delay = review.owner.email_settings.owner[:reply_to_me]
        else
          delay = commentee.email_settings.participant[:reply_to_me]
        end

        case delay
        when EmailSetting::NONE
          # do nothing
        when EmailSetting::INSTANT
          UserMailer.delay.comment_email(@comment, commentee)
        else
          if not MailSummaryJob.exists?(commentee.id, 
                                        :reply_to_me_summary_email, delay)
            Delayed::Job.enqueue(
              MailSummaryJob.new(review.owner.id, 
                                 :reply_to_me_summary_email,
                                 delay), 
              :run_at => delay.days.from_now.to_date)
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
