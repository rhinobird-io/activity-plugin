class Exchange < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :prize_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validates :exchange_time, presence: true
  validates :status, presence: true, inclusion: {in: [Constants::EXCHANGE_STATUS::NEW, Constants::EXCHANGE_STATUS::SENT], message: "%{value} is not a valid status"}

  belongs_to :user
  validates :user, presence: true
  belongs_to :prize
  validates :prize, presence: true
end