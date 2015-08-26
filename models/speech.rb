class Speech < ActiveRecord::Base

  belongs_to :speaker, :class_name => :User, :foreign_key => "user_id"

  has_many :speeches_users, :class_name => :Audience, :foreign_key => "speech_id"
  # users who have applied as audiences
  has_many :audiences, :through => :speeches_users, :source => :user

  has_many :attendances
  # users who really attended this speech, including as audiences and speakers
  has_many :participants, :through => :attendances, :source => :user
end