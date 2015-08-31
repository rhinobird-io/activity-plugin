class Exchange < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :prize_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validates :exchange_time, presence: true

  belongs_to :user
  validates :user, presence: true
  belongs_to :prize
  validates :prize, presence: true
end