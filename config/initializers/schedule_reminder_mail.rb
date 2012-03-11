
Rails::Application.initializer "reminder_mail_job.schedule", :after => "active_record.initialize_database" do |app|
  ReminderMailJob.schedule(Time.now.end_of_day + 5.hour)
end
