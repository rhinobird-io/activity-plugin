class User < ActiveRecord::Base
  validates :role, presence: true, inclusion: {in: [Constants::USER_ROLE::USER, Constants::USER_ROLE::ADMIN], message: "%{value} is not a valid role"}
  validates :point_available, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validates :point_total, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }

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
    self.role == Constants::USER_ROLE::ADMIN
  end

  def change_point_available(offset)
    self.point_available += offset
    halt 400 if self.point_available < 0
  end
  def change_point(offset)
    self.point_total += offset
    if self.point_total < 0
      self.point_total = 0
    end
    self.point_available += offset
    if self.point_available < 0
      self.point_available = 0
    end
  end

  def load_point_history()
    exchanges = self.exchanges.includes(:prize)
    attendances = self.attendances.includes(:speech)

    points_history = []
    exchanges.each do |exchange|
      points_history.push({
        id: "exchange_" + exchange.id.to_s,
        prizeId: exchange.prize_id,
        time: exchange.exchange_time,
        title: exchange.prize.description,
        category: "exchange",
        point: exchange.point
        })
    end

    attendances.each do |attendance|
      points_history.push({
        id: "attendance_" + attendance.id.to_s,
        speechId: attendance.speech_id,
        time: attendance.speech.time,
        title: attendance.speech.title,
        category: "gain",
        point: attendance.point
        })
    end

    points_history.sort! { |a, b| b[:time] <=> a[:time] }
  end

  def as_json(options={})
    options[:except] ||= [:created_at, :updated_at]
    super(options)
  end
end
