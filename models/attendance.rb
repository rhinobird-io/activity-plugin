class Attendance < ActiveRecord::Base
  validates :point, :numericality => { :greater_than_or_equal_to => 0 }

  belongs_to :user
  belongs_to :speech
end