class Exchange < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :prize_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :point, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :exchange_time, presence: true

  belongs_to :user
  belongs_to :prize
end