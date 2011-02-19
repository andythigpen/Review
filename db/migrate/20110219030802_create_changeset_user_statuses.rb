class CreateChangesetUserStatuses < ActiveRecord::Migration
  def self.up
    create_table :changeset_user_statuses do |t|
      t.boolean :accepted
      t.references :user
      t.references :changeset
      t.timestamps
    end
  end

  def self.down
    drop_table :changeset_user_statuses
  end
end
