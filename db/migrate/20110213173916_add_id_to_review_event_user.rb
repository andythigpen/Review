class AddIdToReviewEventUser < ActiveRecord::Migration
  def self.up
    add_column :review_event_users, :id, :primary_key
    add_index :review_event_users, :id
  end

  def self.down
    remove_index :review_event_users, :id
    remove_column :review_event_users, :id
  end
end
