class UserMailer < ActionMailer::Base
  default :from => APP_CONFIG['email_from']

  def welcome_email(user)
    @user = user
    @url = t :app_url
    mail(:to => user.email,
         :subject => "Thanks for Registering for Review")
  end

  def review_request_email(reviewer, reviewee, review_event)
    @reviewer = reviewer
    @reviewee = reviewee
    @review_event = review_event
    @url = APP_CONFIG['url']
    mail(:to => reviewer.email, :subject => "Review Request")
  end

  def status_email(status, reviewer, reviewee)
    @status = status
    @changeset = status.changeset
    @reviewee = reviewee
    @reviewer = reviewer
    @url = APP_CONFIG['url']
    mail(:to => reviewee.email, :subject => "Review Status Change")
  end
end
