class AddIndexToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, [:leftline, :rightline], :name => "line_index"
    add_index :comments, :leftline
    add_index :comments, :rightline
  end

  def self.down
    remove_index :comments, :rightline
    remove_index :comments, :leftline
    remove_index :comments, :name => "line_index"
  end
end
