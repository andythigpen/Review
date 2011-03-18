module HomeHelper
  def recent_comments(days, limit)
    Comment.where(:updated_at => days..Time.now).order("updated_at DESC").limit(limit)
  end
end
