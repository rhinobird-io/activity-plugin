class AudienceRegistration < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :speech_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }

  belongs_to :user
  validates :user, presence: true
  belongs_to :speech
  validates :speech, presence: true
end