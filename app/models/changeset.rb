class Changeset < ActiveRecord::Base
  has_many :diffs
  belongs_to :request
end
