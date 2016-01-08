class Ruian
  class Fetcher

    def parse_rows(queue, &block)
      row_files.each do |file|
        Ruian::Parser.foreach(file) do |attributes|
          attributes = attributes.collect(&:last)
          model = Ruian::Model::Row.new(*attributes)
          queue.push(model, file)
        end
        yield
      end
    end

    def parse_regions(queue, &block)
      Ruian::Parser.foreach(region_file, encoding: 'utf-8') do |attributes|
        attributes = attributes.collect(&:last)
        model = Ruian::Model::Region.new(*attributes)
        queue.push(model, region_file)
      end
      yield
    end

    def parse_counties(queue, &block)
      Ruian::Parser.foreach(county_file, encoding: 'utf-8') do |attributes|
        attributes = attributes.collect(&:last)
        model = Ruian::Model::County.new(*attributes)
        queue.push(model, county_file)
      end
      yield
    end

    def parse_counties_integration(queue, &block)
      Ruian::Parser.foreach(county_integration_file) do |attributes|
        attributes = attributes.collect(&:last)
        model = Ruian::Model::CountyIntegration.new(*attributes)
        queue.push(model, county_integration_file)
      end
      yield
    end

    def parse_regions_integration(queue, &block)
      Ruian::Parser.foreach(region_integration_file) do |attributes|
        attributes = attributes.collect(&:last)
        model = Ruian::Model::RegionIntegration.new(*attributes)
        queue.push(model, region_integration_file)
      end
      yield
    end

    def row_files
      @files ||= Dir.glob(Ruian.root.join('fixtures/CSV', '*.csv'))
    end

    def region_file
      @region_file = Ruian.root.join('fixtures', 'regions.csv')
    end

    def county_file
      @county_file = Ruian.root.join('fixtures', 'counties.csv')
    end

    def county_integration_file
      @count_integration_file = Ruian.root.join('fixtures', 'vazby-okresy-cr.csv')
    end

    def region_integration_file
      @city_integration_file = Ruian.root.join('fixtures', 'vazby-cr.csv')
    end
  end
end
