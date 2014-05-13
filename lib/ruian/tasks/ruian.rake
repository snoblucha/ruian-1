require 'ruian'

namespace :ruian do
  desc "Update address files"
  task :update_files do
    updater = Ruian::FilesUpdater.new
    updater.update!
  end

  desc "Update counties and regions files"
  task :update_enums do
    updater = Ruian::EnumUpdater.new
    updater.update!
  end

  desc "Update all files"
  task :update_all => [:update_files, :update_enums]
end
