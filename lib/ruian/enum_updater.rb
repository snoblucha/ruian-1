require 'open-uri'
require 'fileutils'
require 'zip'

class Ruian
  class EnumUpdater < RuianUpdater

    def url
      "http://vdp.cuzk.cz/vymenny_format/csv/#{most_recent_file}_strukt_ADR.csv.zip"
    end

    def file_name
      'enum.zip'
    end

    def extract?(entry, full_path)
      needed.include?(File.basename(entry.name))
    end

    def csv_directory
      directory.join('strukturovane-CSV')
    end

    def needed
      ['vazby-cr.csv', 'vazby-okresy-cr.csv']
    end
  end
end
