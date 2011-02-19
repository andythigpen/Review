class AddSubmittedToChangeset < ActiveRecord::Migration
  def self.up
    add_column :changesets, :submitted, :boolean
  end

  def self.down
    remove_column :changesets, :submitted
  end
end
