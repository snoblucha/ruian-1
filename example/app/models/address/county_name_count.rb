class Address::CountyNameCount < ActiveRecord::Base
  belongs_to :county
  belongs_to :name
  attr_accessible :count, :county_id, :name_id

  validates_presence_of :county_id, :name_id
end
