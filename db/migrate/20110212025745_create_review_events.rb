class CreateReviewEvents < ActiveRecord::Migration
  def self.up
    create_table :review_events do |t|
      t.string :name
      t.text :notes
      t.datetime :duedate
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :review_events
  end
end
