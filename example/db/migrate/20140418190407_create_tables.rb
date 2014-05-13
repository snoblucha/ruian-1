class CreateTables < ActiveRecord::Migration
  def change
    create_table "address_cities", :force => true do |t|
      t.integer  "code",       :null => false
      t.string   "name",       :null => false
      t.integer  "county_id"
      t.integer  "region_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "address_cities", ["code"], :name => "index_address_cities_on_code"
    add_index "address_cities", ["county_id"], :name => "index_address_cities_on_county_id"
    add_index "address_cities", ["region_id"], :name => "index_address_cities_on_region_id"

    create_table "address_city_parts", :force => true do |t|
      t.integer  "code",       :null => false
      t.string   "name",       :null => false
      t.integer  "city_id",    :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "address_city_parts", ["city_id"], :name => "index_address_city_parts_on_city_id"

    create_table "address_counties", :force => true do |t|
      t.integer  "code"
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "address_county_name_counts", :force => true do |t|
      t.integer "county_id",                :null => false
      t.integer "name_id",                  :null => false
      t.integer "count",     :default => 0, :null => false
    end

    add_index "address_county_name_counts", ["county_id"], :name => "index_address_county_name_counts_on_county_id"
    add_index "address_county_name_counts", ["name_id"], :name => "index_address_county_name_counts_on_name_id"

    create_table "address_momc_names", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "address_mop_names", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "address_names", :force => true do |t|
      t.string   "name",       :null => false
      t.integer  "type",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "address_places", :force => true do |t|
      t.integer  "e"
      t.integer  "p"
      t.string   "o"
      t.string   "zip"
      t.integer  "code",                              :null => false
      t.integer  "street_name_id"
      t.integer  "mop_name_id"
      t.integer  "momc_name_id"
      t.integer  "city_id"
      t.integer  "city_part_id"
      t.float    "longitude"
      t.float    "latitude"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.boolean  "imported",       :default => false, :null => false
    end

    add_index "address_places", ["city_id"], :name => "index_address_places_on_city_id"
    add_index "address_places", ["city_part_id"], :name => "index_address_places_on_city_part_id"
    add_index "address_places", ["code"], :name => "index_address_places_on_code"
    add_index "address_places", ["momc_name_id"], :name => "index_address_places_on_momc_name_id"
    add_index "address_places", ["mop_name_id"], :name => "index_address_places_on_mop_name_id"
    add_index "address_places", ["street_name_id"], :name => "index_address_places_on_street_name_id"

    create_table "address_regex_indices", :force => true do |t|
      t.string   "target_table"
      t.integer  "target_id"
      t.string   "regex"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    add_index "address_regex_indices", ["target_id"], :name => "index_address_regex_indices_on_target_id"

    create_table "address_region_name_counts", :force => true do |t|
      t.integer "region_id",                :null => false
      t.integer "name_id",                  :null => false
      t.integer "count",     :default => 0, :null => false
    end

    add_index "address_region_name_counts", ["name_id"], :name => "index_address_region_name_counts_on_name_id"
    add_index "address_region_name_counts", ["region_id"], :name => "index_address_region_name_counts_on_region_id"

    create_table "address_regions", :force => true do |t|
      t.integer  "ruian_code"
      t.string   "ruian_name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "mvcr_code"
      t.string   "mvcr_name"
    end

    create_table "address_street_names", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "contract_requests", :force => true do |t|
      t.string   "token",                               :null => false
      t.integer  "original_supplier_id"
      t.text     "input_data"
      t.text     "output_data"
      t.integer  "status",               :default => 1, :null => false
      t.text     "status_message"
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
    end

    add_index "contract_requests", ["original_supplier_id"], :name => "index_contract_requests_on_original_supplier_id"

    create_table "contract_scans", :force => true do |t|
      t.integer  "request_id"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      t.datetime "created_at",                        :null => false
      t.datetime "updated_at",                        :null => false
      t.integer  "status",             :default => 1, :null => false
      t.text     "output"
      t.text     "ocr_params"
    end

    add_index "contract_scans", ["request_id"], :name => "index_contract_scans_on_request_id"

    create_table "contract_suppliers", :force => true do |t|
      t.string   "name"
      t.string   "code"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.text     "ocr_params"
    end

    create_table "vehicle_manufacturer", :id => false, :force => true do |t|
      t.integer "id"
      t.string  "manufacturer", :null => false
    end

    create_table "vehicle_model", :id => false, :force => true do |t|
      t.string  "code",                               :null => false
      t.string  "model",                              :null => false
      t.integer "internal_id"
      t.integer "manufacturer_id"
      t.boolean "insurance",       :default => false, :null => false
    end

  end
end
