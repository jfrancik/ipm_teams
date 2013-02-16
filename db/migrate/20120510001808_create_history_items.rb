class CreateHistoryItems < ActiveRecord::Migration
  def self.up
    create_table :history_items do |t|
      t.integer :team_id
      t.integer :user_id
      t.integer :deliverable_id
      t.boolean :submitted
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :history_items
  end
end
