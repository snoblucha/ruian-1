class Ruian
  class Model
    class Row < Struct.new(:adm_code, :city_code, :city_name, :momc_code,
                           :momc_name, :mop_code, :mop_name, :city_part_code,
                           :city_part_name, :street_name_code, :street_name, :so_type,
                           :e, :o, :o_code, :zip, :gis_y, :gis_x, :valid_from)
    end
  end
end
