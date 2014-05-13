class Address::Name < ActiveRecord::Base
  attr_accessible :name, :type
  self.inheritance_column = :sti_type

  has_many :county_name_counts, :dependent => :delete_all
  has_many :region_name_counts, :dependent => :delete_all

  has_enum :type, :class_name => 'Address::NameType'

  def self.find_and_touch(name, type)
    if n = where(:type => type, :name => name).first
      n.touch
    else
      n = create!(:type => type, :name => name)
    end
    n
  end
end
