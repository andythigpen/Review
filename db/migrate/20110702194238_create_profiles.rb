class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.belongs_to :user
      t.string :first_name
      t.string :last_name
      t.string :display_type

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
