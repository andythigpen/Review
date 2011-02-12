class CreateDiffs < ActiveRecord::Migration
  def self.up
    create_table :diffs do |t|
      t.string :origin_file
      t.string :updated_file
      t.text :contents

      t.timestamps
    end
  end

  def self.down
    drop_table :diffs
  end
end
