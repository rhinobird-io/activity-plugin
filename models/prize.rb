class Prize < ActiveRecord::Base
  validates :name, presence: true
  validates :price, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validates :exchanged_times, presence: true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  # exchange history of this goods
  has_many :exchanges
end