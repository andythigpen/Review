class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :user

  def get_review_event
    c = self.commentable
    c = c.commentable until c.class != Comment
    return c.changeset.review_event if c.is_a?(Diff) || c.is_a?(ChangesetUserStatus)
    return c.review_event if c.is_a?(Changeset)
  end

  def get_changeset
    c = self.commentable
    c = c.commentable until c.class != Comment
    return c.changeset if c.is_a?(Diff) || c.is_a?(ChangesetUserStatus)
    return c if c.is_a?(Changeset)
  end

  def text_format
    result = self.content.gsub(/\{\{\{/, "\n")
    result.gsub!(/\}\}\}/, "\n")
    result.gsub!(/'''(.*?)'''/, "\\1")
    result
  end

  def html_format
    result = self.content.gsub(/\{\{\{/, "<pre>")
    result.gsub!(/\}\}\}/, "</pre>")
    result.gsub!(/'''(.*?)'''/, "<strong>\\1</strong>")
    result.html_safe
  end

  def is_deleted?
    return ! self.deleted_at.nil?
  end

  def is_reply_to?(user)
    self.commentable.class == Comment and self.commentable.user == user
  end

  def has_replies?
    return ! Comment.where(
      "commentable_id = ? AND commentable_type = ? AND deleted_at IS NULL", 
      self.id, "Comment").limit(1).empty?
  end

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def self.deleted
    where("deleted_at IS NOT NULL")
  end

  def self.not_deleted
    where("deleted_at IS NULL")
  end
end
