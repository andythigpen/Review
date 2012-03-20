class MailSummaryJob < Struct.new(:user_id, :mail_method, :time_period)

  def self.exists?(user_id, mail_method, time_period)
    Delayed::Job.where(['handler = ? and failed_at is null', handler(user_id, mail_method, time_period)]).count(:all) > 0
  end

  def self.handler(user_id, mail_method, time_period)
    "--- !ruby/struct:MailSummaryJob \nuser_id: #{user_id}\nmail_method: :#{mail_method}\ntime_period: #{time_period}\n"
  end

  def perform
    begin
      UserMailer.send(self.mail_method, 
                      self.user_id, 
                      self.time_period).deliver
    rescue AbortMailerException => e
      # don't send the mail
    end
  end
end
