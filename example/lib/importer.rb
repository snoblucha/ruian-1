ADDRESS_IMPORT_BATCH_SIZE = 10

class Importer
  def initialize
    @headers = nil
    @street_name_cache = {}
    @mop_name_cache = {}
    @momc_name_cache = {}
    @city_cache = {}
    @city_part_cache = {}
    @addresses = []
    @parse_start = Time.now()
  end

  def import_row(row)
    attrs = {}

    case row.so_type
      when 'č.p.'
        attrs[:p] = row.e
        attrs[:e] = nil
      when 'č.ev.'
        attrs[:e] = row.e
        attrs[:p] = nil
      else
        raise "Unknown \"Typ SO\" in row #{row.inspect}"
    end
    attrs[:o] = row.o.to_s + row.o_code.to_s
    attrs[:o] = nil if attrs[:o].blank?

    attrs[:zip] = row.zip
    #raise "Empty \"PSČ\" in row #{row.inspect}" if attrs[:zip].blank?

    attrs[:code] = row.adm_code

    attrs[:street_name] = street_name(row.street_name)
    attrs[:mop_name] = mop_name(row.mop_name)
    attrs[:momc_name] = momc_name(row.momc_name)

    attrs[:city] = city(row.city_code, :name => row.city_name)
    attrs[:city_part] = city_part(row.city_part_code, :name => row.city_part_name, :city => attrs[:city])
    converter = JTSK::Converter.new
    result = converter.to_wgs48(row.gis_x.to_f, row.gis_y.to_f)
    attrs[:longitude], attrs[:latitude] = result.longitude, result.latitude
    add_address(attrs)
  end

  def import_region(region)
    model = Address::Region.find_or_initialize_by_mvcr_code(region.mvcr_code)
    model.mvcr_name = region.mvcr_name
    model.ruian_code = region.ruian_code
    model.ruian_name = region.ruian_name
    model.save!
  end

  def import_county(county)
    model = Address::County.find_or_initialize_by_code(county.code)
    model.name = county.name
    model.save!
  end

  def import_countyintegration(county_integration)
    Address::City.transaction do
      if o = Address::City.find_by_code(county_integration.obec_code)
        county = Address::County.find_by_code!(county_integration.pou_code)
        o.county = county
        o.save!
      end
    end
  end

  def import_regionintegration(region_integration)
    Address::City.transaction do
      if o = Address::City.find_by_code(region_integration.obec_code)
        region = Address::Region.find_by_ruian_code!(region_integration.vusc_code)
        o.region = region
        o.save!
      end
    end
  end

  def finalize!
    flush_addresses

    Address::Place.transaction do
      Address::Place.where(:imported => false).delete_all
      Address::Place.where(:imported => true).update_all(:imported => false)
    end

    # remove untouched things
    [
      Address::City,
      Address::CityPart,
      Address::County,
      Address::MomcName,
      Address::MopName,
      Address::Region,
      Address::StreetName
    ].each do |model|
      model.where('updated_at < ?', @parse_start).destroy_all
    end
  end

  private

  def flush_addresses
    Address::Place.import(@addresses, :validate => false)
    @addresses.clear
  end

  def street_name(name)
    if name.present?
      @street_name_cache[name] ||= touch Address::StreetName.find_or_create_by_name!(name)
    else
      nil
    end
  end

  def mop_name(name)
    if name.present?
      @mop_name_cache[name] ||= touch Address::MopName.find_or_create_by_name!(name)
    else
      nil
    end
  end

  def momc_name(name)
    if name.present?
      @momc_name_cache[name] ||= touch Address::MomcName.find_or_create_by_name!(name)
    else
      nil
    end
  end


  def city(code, attrs)
    # todo update?
    @city_cache[code] ||= touch Address::City.find_or_create_by_code!(code, attrs)
  end

  def city_part(code, attrs)
    if code.present?
      #todo update?
      @city_part_cache[code] ||= touch Address::CityPart.find_or_create_by_code!(code, attrs)
    else
      nil
    end
  end

  def add_address(attrs)
    a = Address::Place.new(attrs)
    a.imported = true

    @addresses << a

    flush_addresses if @addresses.size > ADDRESS_IMPORT_BATCH_SIZE
  end

  def touch(o)
    o.touch if o.updated_at < @parse_start
    o
  end
end
