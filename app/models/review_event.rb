class ReviewEvent < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :review_event_users do
    def active
      joins(:user).where("deleted_at IS NULL")
    end
  end
  has_many :reviewers, :through => :review_event_users, :source => :user,
    :conditions => ["deleted_at IS NULL"]
  has_many :required_reviewers, :through => :review_event_users, 
    :source => :user, 
    :conditions => ["optional = ? AND deleted_at IS NULL", false]
  has_many :optional_reviewers, :through => :review_event_users, 
    :source => :user, 
    :conditions => ["optional = ? AND deleted_at IS NULL", true]
  accepts_nested_attributes_for :review_event_users, :allow_destroy => true,
        :reject_if => proc { |attributes| !attributes['_destroy'] and attributes['user_id'].blank? }
  has_many :changesets, :dependent => :destroy

  validates_presence_of :name

  # returns a changeset user status object for given user
  def status_for(user, changeset = nil)
    changeset = self.changesets.last_submitted if changeset.nil?
    ChangesetUserStatus.find_by_user_id_and_changeset_id(user.id, changeset.id)
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

  def waiting_for(changeset = nil)
    return [] if changeset.nil? && self.changesets.last_submitted.nil?
    self.required_reviewers.select {|r| r if !status_for(r, changeset) }
  end

  def self.search(key)
    where("review_events.name LIKE ? OR review_events.notes LIKE ? OR review_events.buglink LIKE ?", "%#{key}%", "%#{key}%", "%#{key}%")
  end
end
