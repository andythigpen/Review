class AddOptionalToReviewEventUser < ActiveRecord::Migration
  def self.up
    change_table :review_event_users do |t|
      t.boolean :optional, :default => false
    end
  end

  def self.down
    remove_column :review_event_users, :optional
  end
end
