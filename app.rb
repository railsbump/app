require 'cuba'
require 'cuba/mote'
require 'scrivener'
require 'sequel'

DATABASE_URL = ENV.fetch 'DATABASE_URL'

Cuba.plugin Cuba::Mote

DB = Sequel.connect DATABASE_URL

Dir['./lib/**/*.rb'].each    { |f| require f }
Dir['./models/**/*.rb'].each { |f| require f }
Dir['./routes/**/*.rb'].each { |f| require f }

Cuba.plugin HtmlHelpers
Cuba.plugin RoutesHelpers

Cuba.define do
  on root do
    res.redirect '/gems'
  end

  on 'gems' do
    run Gems
  end

  on default do
    not_found
  end
end
