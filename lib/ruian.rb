require "ruian/version"
require 'ruby-progressbar'
require 'ruian/parser'
require 'ruian/model'
require 'ruian/queue'
require 'ruian/fetcher'
require 'ruian/ruian_updater'
require 'ruian/files_updater'
require 'ruian/enum_updater'
require 'ruian/importer'
require 'ruian/railtie' if defined?(Rails)
require 'logger'

class Ruian
  attr_accessor :queue, :fetcher, :importer

  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new($stdout)

  def self.load_tasks
    Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
  end

  def self.root
    Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
  end

  def initialize(options = {})
    self.fetcher  = options[:fetcher]  || Ruian::Fetcher.new
    self.importer = options[:importer] || Ruian::Importer.new
    self.queue    = Ruian::Queue.new(importer)
  end

  def fetch_rows
    count = fetcher.row_files.count
    bar = ProgressBar.create(total: count,
                             title: "Importing #{count} row files.",
                             format: "%a |%b>>%i| %c/%C %p%% %t")

    self.fetcher.parse_rows(self.queue) { bar.increment }
  end

  def fetch_regions
    bar = ProgressBar.create(total: 1,
                             title: 'Importing 1 region file.',
                             format: "%a |%b>>%i| %c/%C %p%% %t")

    self.fetcher.parse_regions(self.queue) { bar.increment }
  end

  def fetch_counties
    bar = ProgressBar.create(total: 1,
                             title: 'Importing 1 county file.',
                             format: "%a |%b>>%i| %c/%C %p%% %t")

    self.fetcher.parse_counties(self.queue) { bar.increment }
  end

  def fetch_integrate_counties
    bar = ProgressBar.create(total: 1,
                             title: 'Importing 1 county integration file.',
                             format: "%a |%b>>%i| %c/%C %p%% %t")

    self.fetcher.parse_counties_integration(self.queue) { bar.increment }
  end

  def fetch_integrate_regions
    bar = ProgressBar.create(total: 1,
                             title: 'Importing 1 region integration file.',
                             format: "%a |%b>>%i| %c/%C %p%% %t")

    self.fetcher.parse_regions_integration(self.queue) { bar.increment }
  end

  def all
    fetch_rows
    fetch_regions
    fetch_counties
    fetch_integrate_counties
    fetch_integrate_regions
    self.importer.finalize!
  end
end

