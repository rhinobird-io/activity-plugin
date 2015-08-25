class User < ActiveRecord::Base
  validates :point, :numericality => { :greater_than_or_equal_to => 0 }
end