module HomeHelper
  def recent_comments(days, limit)
    comments = Comment.where(:updated_at => days..Time.now).
      includes(:commentable).order("updated_at DESC").limit(limit)
    comments.select {|c| ! c.is_deleted? && c.get_changeset.try(:submitted) }
  end

  def recent_submitted_changesets(days, limit)
    Changeset.where(:updated_at => days..Time.now, 
                    :submitted => true).includes(:review_event => :owner).
                    order("updated_at DESC").limit(limit)
  end

  def all_recent(days, limit)
    comments = recent_comments(days, limit)
    changesets = recent_submitted_changesets(days, limit)
    combined = comments | changesets
    combined.sort! {|a,b| b.updated_at <=> a.updated_at}
  end
end
