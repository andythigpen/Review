module MailHelper
  def schedule_email(options={})
    if not options[:time_period]
      raise "Missing time_period"
    elsif not options[:user]
      raise "Missing user"
    elsif not options[:email_method]
      raise "Missing email_method"
    elsif not options[:summary_method]
      raise "Missing summary_method"
    end
    case options[:time_period]
    when EmailSetting::NONE, nil
      # do nothing
    when EmailSetting::INSTANT
      # UserMailer.delay.status_email(@status, current_user, owner)
      UserMailer.delay.send options[:email_method], *options[:email_method_args]
    else
      if not MailSummaryJob.exists?(options[:user].id, 
                                    options[:summary_method], 
                                    options[:time_period])
        Delayed::Job.enqueue(
          MailSummaryJob.new(options[:user].id, 
                             options[:summary_method], 
                             options[:time_period]), 
                             :run_at => 
                                EmailSetting.run_date(options[:time_period]))
      end
    end
  end

end
