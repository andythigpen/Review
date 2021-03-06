class UserMailer < ActionMailer::Base
  default :from => APP_CONFIG['email_from']
  helper :application

  def welcome_email(user)
    @user = user
    @url = t :app_url
    mail(:to => user.email, 
         :subject => "Thanks for Registering for Review")
  end

  def review_request_email(reviewer, reviewee, changeset)
    @reviewer = reviewer
    @reviewee = reviewee
    @review_event = changeset.review_event
    @changeset = changeset
    @url = APP_CONFIG['url']
    subject = "Review Request: #{@review_event.name}"
    mail(:to => reviewer.email, 
         :subject => subject)
  end

  def status_email(status, reviewer, reviewee)
    @status = status
    @changeset = status.changeset
    @reviewee = reviewee
    @reviewer = reviewer
    @comment = @status.comments.first
    @url = APP_CONFIG['url']
    subject = "Review Status Change: #{@changeset.review_event.name} [Comment:#{@comment.id}]"
    mail(:to => reviewee.email, 
         :subject => subject)
  end

  def status_participant_email(status, reviewer, user)
    @status = status
    @changeset = status.changeset
    @reviewer = reviewer
    @comment = @status.comments.first
    @url = APP_CONFIG['url']
    subject = "Review Status Change: #{@changeset.review_event.name} [Comment:#{@comment.id}]"
    mail(:to => user.email, 
         :subject => subject)
  end

  def comment_email(comment, commentee)
    @comment = comment
    @commenter = comment.user
    @commentee = commentee
    @url = APP_CONFIG['url']
    if comment.commentable.class == Comment
      @subject = "Reply to your comment [Comment:#{@comment.id}]"
    else
      @subject = "New comment [Comment:#{@comment.id}]"
    end
    mail(:to => commentee.email, 
         :subject => @subject)
  end

  def comment_participant_email(comment, user)
    @comment = comment
    @commenter = comment.user
    @review = comment.get_review_event
    @url = APP_CONFIG['url']
    mail(:to => user.email, 
         :subject => "New comment [Comment:#{@comment.id}]")
  end

  def reminder_email(review_event, reviewer)
    @url = APP_CONFIG['url']
    @reviewer = reviewer
    @review_event = review_event
    subject = "Review Reminder: #{@review_event.name}"
    mail(:to => reviewer.email, 
         :subject => subject)
  end

  def review_change_email(reviewer, reviewee, changeset)
    @reviewer = reviewer
    @reviewee = reviewee
    @review_event = changeset.review_event
    @changeset = changeset
    @url = APP_CONFIG['url']
    subject = "Review Changed: #{@review_event.name}"
    mail(:to => reviewer.email, 
         :subject => subject)
  end

  #
  # Summary Emails
  #
  def reply_to_me_summary_email(user_id, time_period)
    @url = APP_CONFIG['url']
    #TODO there is probably a better way to do this...
    @comments = Comment.not_deleted.where(["created_at >= ?",
                                          time_period.days.ago])
    @comments = @comments.select do |c|
      c.commentable.class == Comment and c.commentable.user.id == user_id
    end
    @time_period = time_period
    @comment_type = "replies"
    if @comments.size == 0
      raise AbortMailerException.new
    end
    mail(:to => User.find(user_id).email, 
         :subject => "Replies to me summary", 
         :template_name => "comment_summary")
  end

  def comment_to_anyone_summary_email(user_id, time_period)
    @url = APP_CONFIG['url']
    @comments = Comment.not_deleted.where(["created_at >= ?",
                                          time_period.days.ago])
    user = User.find(user_id)
    @comments = @comments.select do |c|
      r = c.get_review_event()
      # notify of new comments if the user participates in that review and is
      # not the one who made the comment
      #
      # also, filter out comments for changeset statuses, because those are
      # sent by the status_change email setting
      r.reviewers.include?(user) or r.owner == user and c.user != user and 
      c.commentable.class != ChangesetUserStatus
    end
    @time_period = time_period
    @comment_type = "new comments"
    if @comments.size == 0
      raise AbortMailerException.new
    end
    mail(:to => user.email, 
         :subject => "New comments summary", 
         :template_name => "comment_summary")
  end

  def status_change_summary_email(user_id, time_period)
    @url = APP_CONFIG['url']
    @statuses = ChangesetUserStatus.where(["created_at >= ? and user_id != ?", 
                                          time_period.days.ago, user_id])
    @time_period = time_period
    user = User.find(user_id)
    if @statuses.size == 0
      raise AbortMailerException.new
    end
    mail(:to => user.email,
         :subject => "Status change summary")
  end

  def new_changeset_summary_email(user_id, time_period)
    @url = APP_CONFIG['url']
    @changesets = Changeset.where(["updated_at >= ? and submitted = ?", 
                                  time_period.days.ago, true])
    @time_period = time_period
    user = User.find(user_id)
    if @changesets.size == 0
      raise AbortMailerException.new
    end
    mail(:to => user.email,
         :subject => "Review request summary",
         :template_name => "review_request_summary_email")
  end
end
