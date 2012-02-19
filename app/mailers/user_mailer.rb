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
    mail(:to => reviewer.email, :subject => subject)
  end

  def status_email(status, reviewer, reviewee)
    @status = status
    @changeset = status.changeset
    @reviewee = reviewee
    @reviewer = reviewer
    @url = APP_CONFIG['url']
    subject = "Review Status Change: #{@changeset.review_event.name}"
    mail(:to => reviewee.email, :subject => subject)
  end

  def comment_email(comment, commenter, commentee)
    @comment = comment
    @commenter = commenter
    @commentee = commentee
    @url = APP_CONFIG['url']
    if comment.commentable.class == Comment
      @subject = "Reply to your comment"
    else
      @subject = "New comment"
    end
    mail(:to => commentee.email, :subject => @subject)
  end

  def reminder_email(review_event, reviewer)
    @url = APP_CONFIG['url']
    @reviewer = reviewer
    @review_event = review_event
    subject = "Review Reminder: #{@review_event.name}"
    mail(:to => reviewer.email, :subject => subject)
  end

  def review_change_email(reviewer, reviewee, changeset)
    @reviewer = reviewer
    @reviewee = reviewee
    @review_event = changeset.review_event
    @changeset = changeset
    @url = APP_CONFIG['url']
    subject = "Review Changed: #{@review_event.name}"
    mail(:to => reviewer.email, :subject => subject)
  end
end
