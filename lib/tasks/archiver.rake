
namespace :review do
  namespace :schedule do
    desc "Schedules auto archiver job"
    task :archiver => :environment do
      AutoArchiveJob.schedule(Time.now.end_of_day + 2.hour)
    end
  end
end

