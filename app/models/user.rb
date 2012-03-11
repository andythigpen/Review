require 'email_settings'

class User < ActiveRecord::Base
  has_many :reviews_owned, :class_name => "ReviewEvent", 
    :dependent => :destroy, :order => "updated_at DESC"
  has_many :review_event_users, :dependent => :destroy
  has_many :review_requests, :through => :review_event_users, 
           :source => :review_event, :order => "updated_at DESC"
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

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username,
                  :first_name, :last_name

  def current_requests
    res = []
    self.review_requests.each do |r|
      latest = r.changesets.last_submitted
      # filter out those without changesets or submitted changesets
      next if latest.nil? 

      yield r if block_given?
      res.push(r)
    end
    res
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

end
