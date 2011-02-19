class ChangesetUserStatus < ActiveRecord::Base
  belongs_to :user
  belongs_to :changeset
end
