class Diff < ActiveRecord::Base
  has_many :comments, :as => :commentable
  belongs_to :changeset
end
