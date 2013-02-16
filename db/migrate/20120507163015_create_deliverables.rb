class CreateDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deliverables do |t|
      t.integer :team_id
      t.integer :index

      t.timestamps
    end
  end

  def self.down
    drop_table :deliverables
  end
end
