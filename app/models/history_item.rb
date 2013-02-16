class HistoryItem < ActiveRecord::Base
  belongs_to :deliverable
  belongs_to :team
  belongs_to :user
end
