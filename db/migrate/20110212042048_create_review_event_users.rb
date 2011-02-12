class CreateReviewEventUsers < ActiveRecord::Migration
  def self.up
    create_table :review_event_users, :id => false do |t|
      t.references :review_event
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :review_event_users
  end
end
