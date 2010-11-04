class NotifyByEmail < ActiveRecord::Migration
  def self.up
    create_table :notify_by_emails do |t|
      t.integer :user_id
      t.integer :target_id
      t.string :target_type
      t.timestamps
    end

  end

  def self.down
    drop_table :notify_by_emails
  end
end
