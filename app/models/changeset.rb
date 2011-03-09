class Changeset < ActiveRecord::Base
  has_many :diffs, :dependent => :destroy
  belongs_to :review_event
  has_many :statuses, :class_name => "ChangesetUserStatus", 
           :dependent => :destroy
  has_many :reviewers, :through => :statuses, :source => :user

  def accepted?
    self.review_event.reviewers.each do |r|
      c = ChangesetUserStatus.find_by_user_id_and_changeset_id(r.id, 
          self.id)
      return false if c.nil? or not c.accepted
    end
    return true
  end

  def rejected?
    self.review_event.reviewers.each do |r|
      c = ChangesetUserStatus.find_by_user_id_and_changeset_id(r.id, 
          self.id)
      return true if not c.nil? and not c.accepted
    end
    return false
  end
end
