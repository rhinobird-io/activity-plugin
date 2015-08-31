class User < ActiveRecord::Base
  validates :role, presence: true, inclusion: {in: [Constants::USER, Constants::ADMIN], message: "%{value} is not a valid role"}
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }

  # speeches whose speaker is this user
  has_many :speeches

  has_many :audience_registrations
  # speeches this user has applied as an audience
  has_many :applied_speeches, :through => :audience_registrations, :source => :speech

  has_many :attendances
  # speeches this user really attended, including as a speaker or an audience
  has_many :attended_speeches, :through => :attendances, :source => :speech

  # exchange history of this user
  has_many :exchanges
  # prizes this user has exchanged
  has_many :prizes, :through => :exchanges

  def is_admin
    self.role == Constants::ADMIN
  end

  def change_point(offset)
    self.point += offset
    if self.point < 0
      self.point = 0
    end
  end

  def as_json(options={})
    options[:except] ||= [:created_at, :updated_at]
    super(options)
  end
end