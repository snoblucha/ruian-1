require 'ruian'
require 'rails'
class Ruian::Railtie < Rails::Railtie
  railtie_name :ruian

  rake_tasks do
    load "ruian/tasks/ruian.rake"
  end
end
