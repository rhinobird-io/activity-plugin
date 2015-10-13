class Comment < ActiveRecord::Base
  validates :user_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :speech_id, presence: true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :comment, presence: true
  validates :step, presence: true, inclusion: {in: [Constants::COMMENT_STEP::AUDITING, Constants::COMMENT_STEP::APPROVE,
                                              Constants::COMMENT_STEP::REJECT, Constants::COMMENT_STEP::DISAGREE], message: "%{value} is not a valid role"}

  belongs_to :user
  validates :user, presence: true
  belongs_to :speech
  validates :speech, presence: true
end