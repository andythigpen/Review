class ReviewEvent < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :review_event_users
  has_many :reviewers, :through => :review_event_users, :source => :user
  has_many :changesets
end
