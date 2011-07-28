class ChangesetUserStatus < ActiveRecord::Base
  belongs_to :user
  belongs_to :changeset

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
