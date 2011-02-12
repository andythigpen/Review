class ReviewEventUser < ActiveRecord::Base
  belongs_to :review_event
  belongs_to :user
end
