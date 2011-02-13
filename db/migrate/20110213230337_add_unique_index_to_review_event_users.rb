class AddUniqueIndexToReviewEventUsers < ActiveRecord::Migration
  def self.up
    add_index :review_event_users, [:review_event_id, :user_id], :unique => true
  end

  def self.down
    remove_index :review_event_users, [:review_event_id, :user_id]
  end
end
