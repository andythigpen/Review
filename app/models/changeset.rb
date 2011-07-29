class Changeset < ActiveRecord::Base
  has_many :diffs, :dependent => :destroy
  belongs_to :review_event
  has_many :statuses, :class_name => "ChangesetUserStatus", 
           :dependent => :destroy
  has_many :reviewers, :through => :statuses, :source => :user

  def accepted?
    return false if self.review_event.reviewers.size == 0
    abstained = 0
    total_reviewers = 0
    self.review_event.reviewers.each do |r|
      c = ChangesetUserStatus.find_by_user_id_and_changeset_id(r.id, 
          self.id)
      #return false if c.nil? or not c.accepted

      return false if c.nil? or not (c.accepted? or c.abstained?)
      abstained += 1 if c.abstained?
      total_reviewers += 1
    end
    return false if total_reviewers == abstained
    return true
  end

  def rejected?
    self.review_event.reviewers.each do |r|
      c = ChangesetUserStatus.find_by_user_id_and_changeset_id(r.id, 
          self.id)
      #return true if not c.nil? and not c.accepted
      return true if not c.nil? and c.rejected?
    end
    return false
  end

  def users_rejected
    ret = []
    self.reviewers.each do |r|
      c = r.changeset_user_statuses.find_by_changeset_id(self.id)
      if c.rejected?
        yield r if block_given?
        ret.push(r)
      end
    end
    ret
  end

  def users_accepted
    ret = []
    self.reviewers.each do |r|
      c = r.changeset_user_statuses.find_by_changeset_id(self.id)
      if c.accepted?
        yield r if block_given?
        ret.push(r)
      end
    end
    ret
  end

  def users_abstained
    ret = []
    self.reviewers.each do |r|
      c = r.changeset_user_statuses.find_by_changeset_id(self.id)
      if c.abstained?
        yield r if block_given?
        ret.push(r)
      end
    end
    ret
  end

  def is_completed?
    return false if not self.submitted
    return true if self.rejected?
    return true if self.accepted?
    return false
  end
end
