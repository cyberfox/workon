class AddTwitterIdToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :twitter_id, :string
    add_index :statuses, :twitter_id
  end

  def self.down
    remove_index :statuses, :twitter_id
    remove_column :statuses, :twitter_id
  end
end
