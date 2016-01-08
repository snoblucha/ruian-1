class Importer

  # increase/decrease depending on your available memory
  ADDRESS_IMPORT_BATCH_SIZE = 100

  def initialize
    @street_name_cache = {}
    @mop_name_cache = {}
    @momc_name_cache = {}
    @city_cache = {}
    @city_part_cache = {}
    @addresses = []
    @parse_start = Time.now()

    @update = true
  end

  def import_row(row, file)
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

    attrs[:code] = row.adm_code

    attrs[:street_name] = street_name(row.street_name)
    attrs[:mop_name] = mop_name(row.mop_name)
    attrs[:momc_name] = momc_name(row.momc_name)

    attrs[:city] = city(row.city_code, name: row.city_name)
    attrs[:city_part] = city_part(row.city_part_code, name: row.city_part_name, city: attrs[:city])
    converter = JTSK::Converter.new
    result = converter.to_wgs48(row.gis_x.to_f, row.gis_y.to_f)
    attrs[:longitude], attrs[:latitude] = result.longitude, result.latitude
    add_address(attrs)
  end

  def import_region(region, file)
    model = Address::Region.find_or_initialize_by(mvcr_code: region.mvcr_code)
    model.mvcr_name = region.mvcr_name
    model.ruian_code = region.ruian_code
    model.ruian_name = region.ruian_name
    model.updated_at = Time.now   # make it dirty
    model.save!
  end

  def import_county(county, file)
    model = Address::County.find_or_initialize_by(code: county.code)
    model.name = county.name
    model.updated_at = Time.now   # make it dirty
    model.save!
  end

  def import_countyintegration(county_integration, file)
    Address::City.transaction do
      if o = Address::City.find_by(code: county_integration.obec_code)
        county = Address::County.find_by!(code: county_integration.pou_code)
        o.county = county
        o.save!
      end
    end
  end

  def import_regionintegration(region_integration, file)
    Address::City.transaction do
      if o = Address::City.find_by(code: region_integration.obec_code)
        region = Address::Region.find_by!(ruian_code: region_integration.vusc_code)
        o.region = region
        o.save!
      end
    end
  end

  def finalize!
    flush_addresses

    Address::Place.transaction do
      Address::Place.where(imported: false).delete_all
      Address::Place.where(imported: true).update_all(imported: false)
    end

    # remove untouched (non-dirty) things
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
    Address::Place.import(@addresses, validate: false)
    @addresses.clear
  end

  def street_name(name)
    if name.present?
      @street_name_cache[name] ||= begin
        street_name = Address::StreetName.find_by(name: name)

        if street_name
          street_name.updated_at = Time.now
          street_name.save!
          street_name
        else
          street_name = Address::StreetName.create(name: name)
        end
      end

    else
      nil
    end
  end

  def mop_name(name)
    if name.present?
      @mop_name_cache[name] ||= begin
        mop_name = Address::MopName.find_by(name: name)

        if mop_name
          mop_name.updated_at = Time.now
          mop_name.save!
          mop_name
        else
          mop_name = Address::MopName.create(name: name)
        end
      end

    else
      nil
    end
  end

  def momc_name(name)
    if name.present?
      @momc_name_cache[name] ||= begin
        momc_name = Address::MomcName.find_by(name: name)

        if momc_name
          momc_name.updated_at = Time.now
          momc_name.save!
          momc_name
        else
          momc_name = Address::MomcName.create(name: name)
        end
      end

    else
      nil
    end
  end

  def city(code, attrs)
    if code.present?
      @city_cache[code] ||= begin
        city = Address::City.find_by(code: code)

        if city
          city.attributes = attrs
          city.updated_at = Time.now
          city.save!
          city
        else
          city = Address::City.create!(attrs.merge(code: code))
        end
      end
    else
      nil
    end
  end

  def city_part(code, attrs)
    if code.present?
      @city_part_cache[code] ||= begin
        city_part = Address::CityPart.find_by(code: code)

        if city_part
          city_part.attributes = attrs
          city_part.updated_at = Time.now
          city_part.save!
          city_part
        else
          city_part = Address::CityPart.create!(attrs.merge(code: code))
        end
      end
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

end
