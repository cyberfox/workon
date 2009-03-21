class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string   :message
      t.integer  :user_id
      t.datetime :done_at

      t.timestamps
    end
    add_index :statuses, [:user_id, :done_at]
  end

  def self.down
    drop_table :statuses
  end
end
