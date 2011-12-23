class ChangesetUserStatus < ActiveRecord::Base
  belongs_to :user
  belongs_to :changeset
  has_many :comments, :as => :commentable, :dependent => :destroy
  accepts_nested_attributes_for :comments,
        :reject_if => proc { |attributes| attributes['content'].blank? }

  def accepted?
    return self.status == CHANGESET_STATUSES[:accept]
  end

  def rejected?
    return self.status == CHANGESET_STATUSES[:reject]
  end

  def abstained?
    return self.status == CHANGESET_STATUSES[:abstain]
  end

  def valid_status?
    return CHANGESET_STATUSES.has_value?(self.status)
  end
end
