require 'ostruct'

class EmailSetting
  NONE = -1
  INSTANT = 0
  DAILY = 1
  WEEKLY = 7
  attr_accessor :participant, :owner

  def initialize
    @participant = {
      :reply_to_me => INSTANT,
      :comment_to_anyone => DAILY,
      :status_change => NONE,
      :new_changeset => INSTANT,
      :edit_review => INSTANT,
      :review_reminder => DAILY,
      :late_reminder => DAILY,
    }

    @owner = {
      :reply_to_me => INSTANT,
      :comment_to_anyone => INSTANT,
      :status_change => INSTANT,
    }
  end

  # def initialize
  #   @participant = OpenStruct.new 
  #   @participant.new_comment_to_me = INSTANT
  #   @participant.new_comment_to_anyone = DAILY
  #   @participant.status_change = NONE
  #   @participant.new_changeset = INSTANT
  #   @participant.edit_review = INSTANT
  #   @participant.review_reminder = DAILY
  #   @participant.late_reminder = DAILY

  #   @owner = OpenStruct.new
  #   @owner.new_comment_to_me = INSTANT
  #   @owner.new_comment_to_anyone = INSTANT
  #   @owner.status_change = INSTANT
  # end
end
