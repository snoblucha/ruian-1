class Address::City < ActiveRecord::Base
  belongs_to :county
  belongs_to :region
  attr_accessible :code, :name

  validates_presence_of :code, :name
end
