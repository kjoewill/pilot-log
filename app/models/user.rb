class User < ActiveRecord::Base
  has_secure_password
  has_many :flight_records

  validates_presence_of :username
  validates_uniqueness_of :username

end
