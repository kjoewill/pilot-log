class User < ActiveRecord::Base
  has_secure_password
  has_many :flight_records

  validates_presence_of :username
  validates_uniqueness_of :username

  def number_of_flights
    self.flight_records.size
  end

  def flight_hours
    self.flight_records.reduce(0) { |sum, rec| sum + rec.duration } / 60.0
  end

  def number_of_landings
    self.flight_records.reduce(0) { |sum, rec| sum + rec.num_landings }
  end

end
