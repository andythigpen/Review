class AddQuoteToProfile < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.string :quote
    end
  end

  def self.down
    remove_column :profiles, :quote
  end
end
