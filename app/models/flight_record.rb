class FlightRecord < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :date, :aircraft_type, :from, :to, :num_landings, :duration
  validates :num_landings, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
  validates :duration, numericality: { only_integer: true, :greater_than_or_equal_to => 1 }

end
