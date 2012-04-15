class RecentActivitySweeper < ActionController::Caching::Sweeper
  observe Changeset, Comment

  def after_save(record)
    expire_fragment('recent_activity')
  end

  def after_update(record)
    expire_fragment('recent_activity')
  end

  def after_destroy(record)
    expire_fragment('recent_activity')
  end

end
