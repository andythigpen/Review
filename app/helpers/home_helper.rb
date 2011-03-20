module HomeHelper
  def recent_comments(days, limit)
    Comment.where(:updated_at => days..Time.now).order("updated_at DESC").limit(limit)
  end

  def recent_submitted_changesets(days, limit)
    changesets = Changeset.where(:updated_at => days..Time.now, :submitted => true).order("updated_at DESC").limit(limit)
  end

  def all_recent(days, limit)
    comments = recent_comments(days, limit)
    changesets = recent_submitted_changesets(days, limit)
    combined = comments | changesets
    combined.sort! {|a,b| b.updated_at <=> a.updated_at}
  end
end
