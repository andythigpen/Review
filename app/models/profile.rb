class Profile < ActiveRecord::Base
  before_validation :clear_avatar
  belongs_to :user
  has_attached_file :avatar, :styles => { :medium => "128x128>", 
                                          :thumb => "24x24>" }
  #attr_accessible :avatar, :first_name, :last_name, :display_type, 
                  #:delete_avatar, :user

  def valid_name?
    return false if self.first_name.nil? and self.last_name.nil?
    not self.first_name.empty? and not self.last_name.empty?
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def full_name_and_username
    self.full_name + " (#{self.user.username})"
  end

  def delete_avatar=(value)
    @delete_avatar = !value.to_i.zero?
  end

  def delete_avatar
    !!@delete_avatar
  end
  alias_method :delete_avatar?, :delete_avatar

  def clear_avatar
    self.avatar = nil if delete_avatar? && !avatar.dirty?
  end

end
