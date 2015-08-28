class Attendance < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :speech_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :role, presence: true, inclusion: {in: [Constants::AUDIENCE, Constants::SPEAKER], message: "%{value} is not a valid role"}
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validates :commented, :inclusion => {:in => [true, false]}

  belongs_to :user
  validates :user, presence: true
  belongs_to :speech
  validates :speech, presence: true
end