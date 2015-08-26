class User < ActiveRecord::Base
  validates :point, :numericality => { :greater_than_or_equal_to => 0 }

  # speeches whose speaker is this user
  has_many :speeches

  # association between speeches and users
  has_many :audiences
  # speeches this user has applied as an audience
  has_many :joined_speeches, :through => :audiences, :source => :speech

  has_many :attendances
  # speeches this user really attended, including as a speaker or an audience
  has_many :attended_speeches, :through => :attendances, :source => :speech

  # exchange history of this user
  has_many :exchanges
  # goods this user has exchanged
  has_many :goods, :through => :exchanges
end