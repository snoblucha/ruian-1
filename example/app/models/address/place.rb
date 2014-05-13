class Address::Place < ActiveRecord::Base
  belongs_to :street_name
  belongs_to :mop_name
  belongs_to :momc_name
  belongs_to :city
  belongs_to :city_part

  attr_accessible :e, :p, :o, :zip, :code, :street_name, :street_name_id, :mop_name, :mop_name_id,
                  :momc_name, :momc_name_id, :city, :city_id, :city_part, :city_part_id, :latitude, :longitude

  validates_presence_of :code, :city_id
  validates_format_of :zip, :with => %r(\A\d{5}\z), :allow_blank => true
end
