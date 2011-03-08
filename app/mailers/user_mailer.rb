class UserMailer < ActionMailer::Base
  default :from => "andyt05@gmail.com"

  def welcome_email(user)
    @user = user
    @url = t :app_url
    mail(:to => user.email,
         :subject => "Thanks for Registering for Review")
  end

end
