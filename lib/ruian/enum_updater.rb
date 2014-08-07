require 'open-uri'
require 'fileutils'
require 'zip'

class Ruian
  class EnumUpdater
    URL = "http://vdp.cuzk.cz/vymenny_format/csv/20140630_strukt_ADR.csv.zip"

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
          name = File.basename(entry.name)
          if needed.include?(name)
            fullpath = fixtures_directory.join(name)
            entry.extract(fullpath)
          end
        end
      end
    end

    def remove_old
      first = fixtures_directory.join(needed.first)
      last = fixtures_directory.join(needed.last)
      FileUtils.rm(first) if File.exists?(first)
      FileUtils.rm(last) if File.exists?(last)
    end

    def remove_temp
      FileUtils.rm(filepath)
    end

    def fixtures_directory
      Ruian.root.join('fixtures')
    end

    def filepath
      Ruian.root.join('fixtures', 'enum.zip')
    end

    def needed
      ['vazby-cr.csv', 'vazby-okresy-cr.csv']
    end
  end
end
