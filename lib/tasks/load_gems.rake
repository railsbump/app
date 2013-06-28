task load_gems: :environment do
  require 'net/http'
  require 'json'

  packages = [
    'railties',
    'actionpack',
    'actionview',
    'activerecord',
    'actionmailer',
    'rails'
  ]

  gems  = []
  mutex = Mutex.new

  packages.map do |package|
    Thread.new {
      path     = "/api/v1/gems/#{package}/reverse_dependencies.json"
      response = Net::HTTP.get "rubygems.org", path

      mutex.synchronize { gems += JSON.parse(response) }
    }
  end.each &:join

  Rubygem.delete_all
  Rubygem.create gems.uniq.map { |gem| { name: gem, status: 'unknown' } }
end
