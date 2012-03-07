class AddEmailSettingsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.text :email_settings
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :email_settings
    end
  end
end
