class AutoArchiveJob
  include Delayed::ScheduledJob

  # run every day at 2 AM local time
  run_every 1.day, :at => {:hour => 2}

  def display_name
    "Auto Archiver"
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
    logger.info "Running Auto Archiver..."
    reviews = ReviewEvent.not_archived.where("updated_at <= ?", 1.month.ago)
    reviews.each do |review|
      logger.info "Checking review #{review.id}"
      if review.changesets.nil?
        logger.info "Archiving review #{review.id}: No changesets"
        # this review hasn't been touched and has no changesets, archive it
        review.archive
        next
      end

      changesets = review.changesets.where("updated_at >= ?", 1.month.ago)
      # changeset was updated less than a month ago, don't archive it
      if changesets.any?
        logger.debug "Recent changesets prevent archiving review #{review.id}"
        next
      end

      archive = true
      review.changesets.each do |changeset|
        if changeset.comments.where("updated_at >= ?", 1.month.ago).any?
          logger.debug "Recent comments for changeset #{changeset.id} prevent archiving review #{review.id}"
          archive = false
          break
        end

        if changeset.statuses.where("updated_at >= ?", 1.month.ago).any?
          logger.debug "Recent statuses for changeset #{changeset.id} prevent archiving review #{review.id}"
          archive = false
          break
        end

        changeset.statuses.each do |status|
          if status.comments.where("updated_at >= ?", 1.month.ago).any?
            logger.debug "Recent status comments for status #{status.id} prevent archiving review #{review.id}"
            archive = false
            break
          end
        end
        break if archive == false

        if changeset.diffs.where("updated_at >= ?", 1.month.ago).any?
          logger.debug "Recent diffs for changeset #{changeset.id} prevent archiving review #{review.id}"
          archive = false
          break
        end

        changeset.diffs.each do |diff|
          if diff.comments.where("updated_at >= ?", 1.month.ago).any?
            logger.debug "Recent diff comments for diff #{diff.id} prevent archiving review #{review.id}"
            archive = false
            break
          end
        end
      end

      if archive
        logger.info "Archiving review #{review.id}: No recent activity."
        review.archive
      end
    end
    logger.info "Auto Archiver finished."
  end

end
