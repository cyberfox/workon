class AddGmailPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gmail_password, :string
  end

  def self.down
    remove_column :users, :gmail_password
  end
end
