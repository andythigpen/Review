class AddDeletedAtToComments < ActiveRecord::Migration
  def up
    add_column :comments, :deleted_at, :datetime
    Comment.all.each do |c|
      if c.user_id.nil?
        c.update_attributes!(:deleted_at => c.updated_at)
      end
    end
  end
  
  def down
    remove_column :comments, :deleted_at
  end
end
