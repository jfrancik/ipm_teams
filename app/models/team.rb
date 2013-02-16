class Team < ActiveRecord::Base
  has_many :users, :order => 'last_name ASC'
  has_many :deliverables, :order => 'index'
  has_many :history_items, :order => 'created_at'

  attr_accessor :csv_crswrk, :csv_test
end
