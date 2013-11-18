require 'cuba'
require 'cuba/mote'
require 'sequel'

DATABASE_URL = ENV.fetch 'DATABASE_URL'

Cuba.plugin Cuba::Mote

DB = Sequel.connect DATABASE_URL

Sequel::Model.plugin :timestamps, update_on_create: true

Dir['./lib/**/*.rb'].each    { |f| require f }
Dir['./models/**/*.rb'].each { |f| require f }
Dir['./routes/**/*.rb'].each { |f| require f }

Cuba.define do
  on root do
    res.redirect '/gems'
  end

  on 'gems' do
    run Rubygems
  end
end
