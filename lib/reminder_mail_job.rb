class ReminderMailJob
  include Delayed::ScheduledJob

  run_every 1.day

  def display_name
    "Reminder Mailer"
  end

  def deliver_emails(events, mail_type)
    events.each do |e|
      c = e.changesets.last_submitted
      next if c.nil? or c.accepted? or c.rejected?
      e.reviewers.each do |r|
        status = e.status_for(r)
        if not status.nil?
          next if status.valid_status?
        end
        if r.email_settings.participant[mail_type] == EmailSetting::DAILY
          UserMailer.reminder_email(e, r).deliver
        end
      end
    end
  end

  def perform
    # due date reminders
    events = ReviewEvent.find(:all, :conditions => [
                                "DATE(duedate) <= ? and DATE(duedate) >= ?", 
                                1.day.from_now, Time.now.to_date])
    deliver_emails(events, :review_reminder)

    # late reminders
    events = ReviewEvent.find(:all, :conditions => [
                                "DATE(duedate) < ?", Time.now.to_date])
    deliver_emails(events, :late_reminder)
  end

end
