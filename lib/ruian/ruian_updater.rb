require 'open-uri'
require 'fileutils'
require 'zip'

class Ruian
  class RuianUpdater
    attr_reader :directory

    def initialize(directory = fixtures_directory)
      @directory = directory
    end

    def update!(remove: true, download_new: false)
      download if !filepath.exist? || download_new
      remove_old
      unpack
      remove_temp if remove
    end

    def download
      puts "Downloading #{url}"
      File.open(filepath, "wb") do |file|
        open(url) do |opened_url|
          file.write(opened_url.read)
        end
      end
    end

    def unpack
      print "Extracting..."
      Zip::File.open(filepath) do |zip_file|
        zip_file.each do |entry|
          fullpath = directory.join(entry.name)
          if extract?(entry, fullpath)
            FileUtils.mkdir_p(File.dirname(fullpath))
            entry.extract(fullpath)
          end
        end
      end
      puts "done"
    end

    def most_recent_file(at = Time.current)
      at.prev_month.at_end_of_month.strftime('%Y%m%d')
    end

    def url
      raise 'Not implemented'
    end

    def file_name
      raise 'Not implemented'
    end

    def remove_temp
      puts "Removing downloaded file #{filepath}"
      FileUtils.rm(filepath)
    end

    def remove_old
      puts "Removing: #{csv_directory}"
      FileUtils.rm_rf(csv_directory)
    end

    def fixtures_directory
      Ruian.root.join('fixtures')
    end

    def csv_directory
      directory.join('CSV')
    end

    def filepath
      directory.join(file_name)
    end

    def extract?(entry, full_path)
      true
    end
  end
end
