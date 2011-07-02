class ReviewEvent < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :review_event_users
  has_many :reviewers, :through => :review_event_users, :source => :user
  accepts_nested_attributes_for :review_event_users, :allow_destroy => true,
        :reject_if => proc { |attributes| !attributes['_destroy'] and attributes['user_id'].blank? }
  has_many :changesets, :dependent => :destroy

  # returns nil if no status yet, or true if accepted, false if rejected
  def status_for(user)
    return nil if self.changesets.nil?
    status = ChangesetUserStatus.find_by_user_id_and_changeset_id(user.id, 
                self.changesets.last.id)
    return nil if status.nil?
    return status.accepted
  end

  def accepted_total
    return self.changesets.last.users_accepted.count
  end

  def reviewers_total
    return self.review_event_users.count
  end
end
