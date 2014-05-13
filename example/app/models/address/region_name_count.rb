class Address::RegionNameCount < ActiveRecord::Base
  belongs_to :region
  belongs_to :name
  attr_accessible :count, :region_id, :name_id

  validates_presence_of :name_id, :region_id
end
