class User < ActiveRecord::Base
  has_secure_password
  has_many :flight_records

  validates_presence_of :username
  validates_uniqueness_of :username

  def slug
    self.username.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def self.find_by_slug(slug)
    self.all.find {|e| e.slug == slug}
  end

end
