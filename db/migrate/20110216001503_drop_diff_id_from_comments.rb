class DropDiffIdFromComments < ActiveRecord::Migration
  def self.up
    remove_index :comments, [:commentable_id, :commentable_type]
    remove_column :comments, :diff_id
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    remove_index :comments, [:commentable_id, :commentable_type]
    add_column :comments, :diff_id, :integer
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
