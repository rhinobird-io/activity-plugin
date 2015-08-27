class AudienceRegistration < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }
  validates :speech_id, presence: true, :numericality => { :greater_than_or_equal_to => 1 }

  belongs_to :user
  belongs_to :speech
end