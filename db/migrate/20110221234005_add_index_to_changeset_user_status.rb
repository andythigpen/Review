class AddIndexToChangesetUserStatus < ActiveRecord::Migration
  def self.up
    add_index :changeset_user_statuses, [:user_id, :changeset_id], 
              :unique => true
  end

  def self.down
    remove_index :changeset_user_statuses, column =>
                 [:user_id, :changeset_id]
  end
end
