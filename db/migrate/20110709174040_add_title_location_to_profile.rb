class AddTitleLocationToProfile < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.string :profession
      t.string :location
    end
  end

  def self.down
    remove_column :profiles, :profession
    remove_column :profiles, :location
  end
end
