class DiffSweeper < ActionController::Caching::Sweeper
  observe Diff, Comment

  def after_save(record)
    expire_for(record)
  end

  def after_update(record)
    expire_for(record)
  end

  def after_destroy(record)
    expire_for(record)
  end

  private

  def expire_for(record)
    if record.is_a?(Diff)
      expire_fragment("diff/#{record.id}/split")
      expire_fragment("diff/#{record.id}/unified")
    elsif record.is_a?(Comment)
      c = record
      c = c.commentable while c.respond_to?(:commentable)
      if c.is_a?(Diff)
        expire_fragment("diff/#{c.id}/split")
        expire_fragment("diff/#{c.id}/unified")
      end
    end
  end

end

