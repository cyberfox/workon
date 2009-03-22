class AddTwitterTimeToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :twitter_created_at, :datetime
    add_index :statuses, [:user_id, :twitter_created_at]
  end

  def self.down
    remove_index :statuses, [:user_id, :twitter_created_at]
    remove_column :statuses, :twitter_created_at
  end
end
