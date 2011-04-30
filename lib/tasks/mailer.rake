
# add this as a cron job to send out reminder emails on a periodic basis
desc "Periodic mailer"
task :reminder_mail => :environment do
    events = ReviewEvent.find(:all, 
                              :conditions => ["DATE(duedate) <= ?", 
                                  1.day.from_now])
    events.each do |e|
        next if e.changesets.last.accepted?
        next if e.changesets.last.rejected?
        e.reviewers.each do |r|
            next if not e.status_for(r).nil?
            puts "Emailing #{r.email} for #{e.name}"
            UserMailer.reminder_email(e, r).deliver
        end
    end
end
