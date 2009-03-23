class AddVisibleStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :visible, :boolean
  end

  def self.down
    remove_column :users, :visible
  end
end
