namespace :ruian_api do
  desc 'Import from ruian'
  task 'import' => :environment do
    Ruian.new(importer: Ruian::Importer.new, fetcher: Ruian::Fetcher.new(Rails.root.join('tmp'))).all
  end

  desc "Update address files"
  task :update_files do
    updater = Ruian::FilesUpdater.new(Rails.root.join('tmp'))
    updater.update!(download_new: ENV['FORCE'].present?, remove: !ENV['KEEP'].present?)
  end

  desc "Update counties and regions files"
  task :update_enums do
    updater = Ruian::EnumUpdater.new(Rails.root.join('tmp'))
    updater.update!(download_new: ENV['FORCE'].present?, remove: !ENV['KEEP'].present?)
  end

  desc "Update all files"
  task :update_all => [:update_files, :update_enums]
end
