class ReviewEvent < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :review_event_users
  has_many :reviewers, :through => :review_event_users, :source => :user
  has_many :required_reviewers, :through => :review_event_users, 
    :source => :user, :conditions => ["optional = ?", false]
  has_many :optional_reviewers, :through => :review_event_users, 
    :source => :user, :conditions => ["optional = ?", true]
  accepts_nested_attributes_for :review_event_users, :allow_destroy => true,
        :reject_if => proc { |attributes| !attributes['_destroy'] and attributes['user_id'].blank? }
  has_many :changesets, :dependent => :destroy

  validates_presence_of :name

  # returns a changeset user status object for given user
  def status_for(user)
    return nil if self.changesets.nil? or self.changesets.last.nil?
    status = ChangesetUserStatus.find_by_user_id_and_changeset_id(user.id, 
                self.changesets.last.id)
    return status
  end

  def accepted_total
    return 0 if not self.changesets.last
    return self.changesets.last.users_accepted.count
  end

  def abstained_total
    return 0 if not self.changesets.last
    return self.changesets.last.users_abstained.count
  end

  def required_total
    return self.required_reviewers.count
  end

  def waiting_for
    self.required_reviewers.select {|r| r if !status_for(r) }
  end

end
