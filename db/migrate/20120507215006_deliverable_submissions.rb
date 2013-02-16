class DeliverableSubmissions < ActiveRecord::Migration
  def self.up
    add_column :deliverables, :submitted, :boolean
    add_column :deliverables, :mark, :integer
  end

  def self.down
    remove_column :deliverables, :submitted
    remove_column :deliverables, :mark
  end
end
