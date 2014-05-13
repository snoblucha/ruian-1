class Address::CityPart < ActiveRecord::Base
  belongs_to :city

  attr_accessible :code, :name, :city, :city_id

  validates_presence_of :city_id, :code, :name
end
