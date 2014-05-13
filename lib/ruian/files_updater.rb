require 'open-uri'
require 'fileutils'
require 'zip'

class Ruian
  class FilesUpdater
    URL = "http://vdp.cuzk.cz/vymenny_format/csv/20140331_OB_ADR_csv.zip"

    def update!
      download
      remove_old
      unpack
      remove_temp
    end

    def download
      File.open(filepath, "wb") do |file|
        open(URL) do |url|
          file.write(url.read)
        end
      end
    end

    def unpack
      Zip::File.open(filepath) do |zip_file|
        zip_file.each do |entry|
          fullpath = fixtures_directory.join(entry.name)
          FileUtils.mkdir_p(File.dirname(fullpath))
          entry.extract(fullpath)
        end
      end
    end

    def remove_temp
      FileUtils.rm(filepath)
    end

    def remove_old
      FileUtils.rm_rf(csv_directory)
    end

    def fixtures_directory
      Ruian.root.join('fixtures')
    end

    def csv_directory
      Ruian.root.join('fixtures', 'CSV')
    end

    def filepath
      Ruian.root.join('fixtures', 'csv.zip')
    end
  end
end
