class Profile < ActiveRecord::Base
  belongs_to :user

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
end
