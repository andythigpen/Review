class ModifyChangesetUserStatus < ActiveRecord::Migration
  def self.up
    remove_index :changeset_user_statuses, :user_id_and_changeset_id
    change_table :changeset_user_statuses do |t|
      #t.remove :accepted
      t.integer :status
    end
    ChangesetUserStatus.reset_column_information
    ChangesetUserStatus.all.each do |c|
      if c.accepted.nil?
        c.update_attribute :status, nil
      elsif c.accepted
        c.update_attribute :status, CHANGESET_STATUSES[:accept]
      else
        c.update_attribute :status, CHANGESET_STATUSES[:reject]
      end
    end
    change_table :changeset_user_statuses do |t|
      t.remove :accepted
    end
    add_index :changeset_user_statuses, [:user_id, :changeset_id]
  end

  def self.down
    remove_index :changeset_user_statuses, :user_id_and_changeset_id
    change_table :changeset_user_statuses do |t|
      t.boolean :accepted
      #t.remove :status
    end
    ChangesetUserStatus.reset_column_information
    ChangesetUserStatus.all.each do |c|
      if c.accepted?
        c.update_attribute :accepted, true
      elsif c.rejected?
        c.update_attribute :accepted, false
      else
        c.update_attribute :accepted, nil
      end
    end
    change_table :changeset_user_statuses do |t|
      t.remove :status
    end
    add_index :changeset_user_statuses, [:user_id, :changeset_id]
  end
end
