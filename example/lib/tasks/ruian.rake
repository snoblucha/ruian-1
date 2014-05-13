desc 'Import from ruian'
task 'ruian:import' => :environment do
  Ruian.new(Importer.new).all
end
