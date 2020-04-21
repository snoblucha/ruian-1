require 'open-uri'
require 'fileutils'
require 'zip'

class Ruian
  class FilesUpdater < RuianUpdater
    def csv_directory
      directory.join('CSV')
    end

    def file_name
      'csv.zip'
    end

    def url
      "http://vdp.cuzk.cz/vymenny_format/csv/#{most_recent_file}_OB_ADR_csv.zip"
    end

    def filepath
      directory.join('csv.zip')
    end
  end
end
