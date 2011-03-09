class ReviewEvent < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id", 
             :validate => true
  has_many :review_event_users
  has_many :reviewers, :through => :review_event_users, :source => :user
  accepts_nested_attributes_for :review_event_users, :allow_destroy => true,
        :reject_if => proc { |attributes| !attributes['_destroy'] and attributes['user_id'].blank? }
  has_many :changesets, :dependent => :destroy
end
