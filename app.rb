require 'cuba'
require 'cuba/mote'
require 'json_serializer'
require 'scrivener'
require 'sequel'

DATABASE_URL = ENV.fetch 'DATABASE_URL'

Cuba.plugin Cuba::Mote

DB = Sequel.connect DATABASE_URL

def require_dir str
  Dir[str].each { |f| require f }
end

require_dir './lib/**/*.rb'
require_dir './models/**/*.rb'
require_dir './helpers/**/*.rb'
require_dir './serializers/**/*.rb'
require_dir './routes/**/*.rb'

Cuba.plugin HtmlHelpers
Cuba.plugin RoutesHelpers

Cuba.define do
  on root do
    res.redirect '/gems'
  end

  on 'gems' do
    run Gems
  end

  on 'gemfile' do
    run Gemfile
  end

  on default do
    not_found
  end
end
