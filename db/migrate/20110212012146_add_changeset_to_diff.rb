class AddChangesetToDiff < ActiveRecord::Migration
  def self.up
    change_table :diffs do |t|
      t.references :changeset
    end
  end

  def self.down
  end
end
