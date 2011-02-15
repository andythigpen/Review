class AddUserIdToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :user_id, :integer
    add_column :comments, :lineno, :integer
  end

  def self.down
    remove_column :comments, :user_id
    remove_column :comments, :lineno
  end
end
