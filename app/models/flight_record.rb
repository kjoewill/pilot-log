class FlightRecord < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :date, :aircraft_type, :from, :to, :num_landings, :duration

end
