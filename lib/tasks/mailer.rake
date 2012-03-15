
namespace :review do
  namespace :schedule do
    desc "Schedules reminder mail job"
    task :reminder => :environment do
      ReminderMailJob.schedule(Time.now.end_of_day + 5.hour)
    end
  end
end
