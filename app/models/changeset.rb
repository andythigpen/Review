class Changeset < ActiveRecord::Base
  has_many :diffs
  belongs_to :review_event
end
