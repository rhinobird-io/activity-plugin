class Good < ActiveRecord::Base
  validates :point, :numericality => { :greater_than_or_equal_to => 0 }
  # exchange history of this goods
  has_many :exchanges
end