class CreateChangesets < ActiveRecord::Migration
  def self.up
    create_table :changesets do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :changesets
  end
end
