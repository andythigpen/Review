class Changeset < ActiveRecord::Base
  has_many :diffs
  belongs_to :review_event
  has_many :statuses, :class_name => "ChangesetUserStatus"
  has_many :reviewers, :through => :statuses, :source => :user
end
