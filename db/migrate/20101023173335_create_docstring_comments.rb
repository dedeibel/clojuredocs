class CreateDocstringComments < ActiveRecord::Migration
  def self.up
    create_table :docstring_comments do |t|
      t.integer :function_id
      t.integer :user_id
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :docstring_comments
  end
end
