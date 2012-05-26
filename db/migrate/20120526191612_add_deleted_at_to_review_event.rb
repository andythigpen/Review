class AddDeletedAtToReviewEvent < ActiveRecord::Migration
  def change
    add_column :review_events, :deleted_at, :datetime
  end
end
