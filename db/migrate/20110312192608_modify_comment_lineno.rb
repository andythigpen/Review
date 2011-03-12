class ModifyCommentLineno < ActiveRecord::Migration
  def self.up
    remove_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, [:commentable_id, :commentable_type], :name => "comment_index"
    change_table :comments do |t|
      t.rename :lineno, :leftline
      t.integer :rightline
    end
  end

  def self.down
    remove_index :comments, [:commentable_id, :commentable_type], :name => "comment_index"
    change_table :comments do |t|
      t.remove :rightline
      t.rename :leftline, :lineno
    end
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
