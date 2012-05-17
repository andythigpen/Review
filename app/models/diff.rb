class Diff < ActiveRecord::Base
  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :changeset

  def left_comments
    left = self.comments.where("leftline IS NOT NULL AND rightline IS NULL").order("leftline ASC")
    left_hash = {}
    left.map do |x|
      left_hash[x.leftline] = [] if left_hash[x.leftline].nil?
      left_hash[x.leftline].push(x)
    end
    return left_hash
  end

  def right_comments
    right = self.comments.where("leftline IS NULL AND rightline IS NOT NULL").order("rightline ASC")
    right_hash = {}
    right.map do |x|
      right_hash[x.rightline] = [] if right_hash[x.rightline].nil?
      right_hash[x.rightline].push(x)
    end
    return right_hash
  end

  def both_comments
    both = self.comments.where("leftline IS NOT NULL AND rightline IS NOT NULL").order("leftline ASC")
    # just order based upon left
    both_hash = {}
    both.map do |x|
      both_hash[x.leftline] = [] if both_hash[x.leftline].nil?
      both_hash[x.leftline].push(x)
    end
    return both_hash
  end

  def overall_comments
    self.comments.where("leftline IS NULL AND rightline IS NULL")
  end

  def additions
    self.contents.lines.reject {|line| line =~ /^[^+]/ }
  end

  def deletions
    self.contents.lines.reject {|line| line =~ /^[^-]/ }
  end

  def was_file_added
    added = false
    context = self.contents.lines.reject {|line| line =~ /^[^@]{2}/ }
    context.each do |line|
      if line =~ /^@@\s+-(\d+)(,(\d+))*\s+\+(\d+)(,(\d+))*\s+@@/
        lineno_left = $1.to_i 
        context_left = $3.to_i
        added = (context_left == 0 and lineno_left == 0)
      end
    end
    return added
  end

  def was_file_deleted
    deleted = false
    context = self.contents.lines.reject {|line| line =~ /^[^@]{2}/ }
    context.each do |line|
      if line =~ /^@@\s+-(\d+)(,(\d+))*\s+\+(\d+)(,(\d+))*\s+@@/
        lineno_right = $4.to_i 
        context_right = $6.to_i
        deleted = (context_right == 0 and lineno_right == 0)
      end
    end
    return deleted
  end
end
