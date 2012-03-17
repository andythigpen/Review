class EmailSetting
  attr_accessor :participant, :owner

  def initialize
    @participant = {
      :reply_to_me => INSTANT,
      :comment_to_anyone => DAILY,
      :status_change => NONE,
      :new_changeset => INSTANT,
      :review_reminder => DAILY,
      :late_reminder => DAILY,
      #:edit_review => INSTANT,
    }

    @owner = {
      :reply_to_me => INSTANT,
      :comment_to_anyone => INSTANT,
      :status_change => INSTANT,
    }
  end

  def self.run_date(setting)
    case setting
    when NONE
    when INSTANT
      Time.now
    when DAILY
      Time.now.end_of_day
    when WEEKLY
      Time.now.end_of_week
    end
  end

  def self.select_options
    [["Never", NONE], ["Instantly", INSTANT], ["Daily Summary", DAILY], 
     ["Weekly Summary", WEEKLY]]
  end

end
