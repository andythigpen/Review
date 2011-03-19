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
end
