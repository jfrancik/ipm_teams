class Contribution < ActiveRecord::Base

  validates_numericality_of :score, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 12

  belongs_to :user
  belongs_to :deliverable

  def submitted?
    deliverable.submitted? && score > 0
  end

  def marked?
    return submitted? && deliverable.marked?
  end

  def not_marked?
    return deliverable.submitted? && !deliverable.marked?
  end

  def submitted_score
    return submitted? ? score : 0
  end

  def mark
    return marked? ? deliverable.mark : 0
  end

  def marked_score
    return marked? ? score : 0
  end

  def marked_partial
    return marked_score * mark
  end

end
