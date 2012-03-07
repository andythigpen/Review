require 'ostruct'

class EmailSetting
  NONE = -1
  INSTANT = 0
  DAILY = 1
  WEEKLY = 7
  attr_accessor :participant, :owner, :NONE, :INSTANT, :DAILY, :WEEKLY

  def initialize
    @participant = OpenStruct.new 
    @participant.new_comment_to_me = INSTANT
    @participant.new_comment_to_anyone = DAILY
    @participant.status_change = NONE
    @participant.new_changeset = INSTANT
    @participant.edit_review = INSTANT
    @participant.review_reminder = DAILY
    @participant.late_reminder = DAILY

    @owner = OpenStruct.new
    @owner.new_comment_to_me = INSTANT
    @owner.new_comment_to_anyone = INSTANT
    @owner.status_change = INSTANT
  end
end
