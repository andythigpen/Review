class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :user

  def get_review_event
    c = self.commentable
    c = c.commentable until c.class != Comment
    c.changeset.review_event
  end

  def get_changeset
    c = self.commentable
    c = c.commentable until c.class != Comment
    c.changeset
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
    return self.user_id.nil?
  end
end
