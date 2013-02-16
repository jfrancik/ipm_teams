class UserTestMarks < ActiveRecord::Migration
  def self.up
    add_column :users, :test_mark_A, :integer, :default => -1
    add_column :users, :test_mark_B, :integer, :default => -1
    add_column :users, :test_mark, :integer, :default => -1
  end

  def self.down
    remove_column :users, :test_mark_A
    remove_column :users, :test_mark_B
    remove_column :users, :test_mark
  end
end
