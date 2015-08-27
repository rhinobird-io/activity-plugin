class Attendance < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :speech_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :role, presence: true, inclusion: {in: ["audience", "speaker"], message: "%{value} is not a valid role"}
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :commented, :inclusion => {:in => [true, false]}

  belongs_to :user
  belongs_to :speech
end