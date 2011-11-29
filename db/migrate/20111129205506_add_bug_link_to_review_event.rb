class AddBugLinkToReviewEvent < ActiveRecord::Migration
  def self.up
    add_column :review_events, :buglink, :string
  end

  def self.down
    remove_column :review_events, :buglink
  end
end
