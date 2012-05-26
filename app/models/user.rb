require 'email_settings'

class User < ActiveRecord::Base
  has_many :reviews_owned, :class_name => "ReviewEvent", 
    :dependent => :destroy, :order => "review_events.updated_at DESC"
  has_many :review_event_users, :dependent => :destroy
  has_many :review_requests, :through => :review_event_users, 
           :source => :review_event, :order => "review_events.updated_at DESC"
  has_many :comments, :dependent => :destroy
  has_many :changeset_user_statuses, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  serialize :email_settings, EmailSetting

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable, :encryptable, 
         :encryptor => :sha1

  default_scope includes(:profile)

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username,
                  :first_name, :last_name

  class NotAuthorized < StandardError; end

  def submitted_requests
    self.review_requests.joins(:changesets).where("changesets.submitted = ?", 
                                                  true).uniq
  end

  def recent_requests(time_period)
    self.submitted_requests.where("changesets.updated_at >= ?", time_period)
  end

  def pending_requests
    # idea from http://stackoverflow.com/questions/2111384/sql-join-selecting-the-last-records-in-a-one-to-many-relationship
    # this selects the last changeset and then eliminates any changesets that
    # have submitted statuses by this user
    self.submitted_requests.joins("LEFT OUTER JOIN changesets c2 ON 
      review_events.id = c2.review_event_id AND changesets.id < c2.id").
      where("c2.id IS NULL AND NOT changesets.id IN 
            (SELECT changesets.id FROM changesets 
            INNER JOIN changeset_user_statuses 
            ON changeset_user_statuses.changeset_id = changesets.id 
            WHERE changeset_user_statuses.user_id = ?)", self.id)
  end

  def requests_due(time_period)
    self.pending_requests.where(
      "review_events.duedate <= ? AND NOT review_events.duedate < ?", 
      time_period, Time.now.to_date)
  end

  def late_requests
    self.pending_requests.where("review_events.duedate < ?", Time.now.to_date)
  end

  def drafts
    self.reviews_owned.joins("LEFT OUTER JOIN changesets ON changesets.review_event_id = review_events.id").where("changesets.submitted IS NULL")
  end

  def profile_name
    if self.profile.nil? or not self.profile.valid_name?
      self.username 
    else
      self.profile.full_name_and_username
    end
  end

  def full_name
    if self.profile.nil? or not self.profile.valid_name?
      self.username 
    else
      self.profile.full_name
    end
  end

  def groups_for(current_user)
    groups = []
    current_user.groups.each do |g|
      groups.push g if g.members.include?(self)
    end
    return groups
  end

  def email_settings
    if read_attribute(:email_settings).nil?
      write_attribute :email_settings, EmailSetting.new
      read_attribute :email_settings
    else
      read_attribute :email_settings
    end
  end

  def email_settings=(val)
    write_attribute :email_settings, val
  end

  def self.serialized_attr_accessor(member, *args)
    args.each do |k|
      eval "
        def #{member}_#{k}
          self.email_settings.#{member}[:#{k}]
        end
        def #{member}_#{k}=(value)
          self.email_settings.#{member}[:#{k}] = value
        end
      "
    end
  end

  serialized_attr_accessor "participant", :reply_to_me, :comment_to_anyone, 
    :status_change, :new_changeset, :edit_review, :review_reminder, 
    :late_reminder
  serialized_attr_accessor "owner", :reply_to_me, :comment_to_anyone, 
    :status_change


  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def self.active
    where("deleted_at IS NULL")
  end

  def self.inactive
    where("deleted_at IS NOT NULL")
  end

  def active_for_authentication?
    super && !deleted_at
  end
end
