class Deliverable < ActiveRecord::Base

  validates_numericality_of :total_score, :greater_than_or_equal_to => :min_score, :less_than_or_equal_to => :max_score

  belongs_to :team
  has_many :contributions, :order => 'id ASC'
  accepts_nested_attributes_for :contributions
  has_many :history_items, :order => 'created_at'

  def name
    case index
      when 0
        return "Project Proposal"
      when 1
        return "Project scope"
      when 2
        return "SWOT"
      when 3
        return "PEST(LE)"
      when 4
        return "Force-Field"
      when 5
        return "Methodology"
      when 6
        return "Cost-Benefit Analysis"
      when 7
        return "WB by Product"
      when 8
        return "WB by Task"
      when 9
        return "Gantt Chart"
      when 10
        return "Project Roles and Responsibilities"
      when 11
        return "Resource Planning"
      when 12
        return "PERT Diagram"
      when 13
        return "Time-boxes"
      when 14
        return "Software Metrics"
      when 15
        return "Early prototype"
      when 16
        return "Risk Analysis"
      when 17
        return "Risk Mitigation/Contingency"
      when 18
        return "Product Quality Plan"
      when 19
        return "Project Control and Monitoring Plan"
      when 20
        return "Project Review"
      when 21
        return "Revised Project Plan"
      when 22
        return "Team Organisation and Development"
      when 23
        return "Revised Prototype"
      when 24
        return "Agile Team Meetings Minutes"
      when 25
        return "Project Poster"
    end
  end

  def mandatory?
    [0, 1, 8, 9, 15, 16, 20, 25].include? index
  end

  def submitted?
    return submitted || mandatory?
  end

  def total_score
    contributions.collect {|c| c.submitted_score}.inject(:+)
  end

  def min_score
    if mandatory?
      12
    else
      0
    end
  end

  def max_score
    if contributions.size <= 4
      return 12
    else
      return 15
    end
  end

  def marked?
    submitted? && mark >= 0
  end

end
