class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :user

  def get_review_event
    c = self.commentable
    # right now only commentables are Diff and Comment
    c = c.commentable until c.class != Comment
    c.changeset.review_event
  end

  def get_changeset
    c = self.commentable
    # right now only commentables are Diff and Comment
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
    result = self.content.gsub(/\{\{\{/, "<div class=\"comment-code\">")
    result.gsub!(/\}\}\}/, "</div>")
    result.gsub!(/'''(.*?)'''/, "<strong>\\1</strong>")
    result.html_safe
  end
end
