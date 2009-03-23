class AddAccessKeyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :access_key, :string
    add_index :users, :access_key
  end

  def self.down
    remove_index :users, :access_key
    remove_column :users, :access_key
  end
end
