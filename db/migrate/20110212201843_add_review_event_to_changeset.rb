class AddReviewEventToChangeset < ActiveRecord::Migration
  def self.up
    change_table :changesets do |t|
      t.references :review_event
    end
  end

  def self.down
    remove_column :review_event_id
  end
end
