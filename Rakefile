# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Ready4rails4::Application.load_tasks

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
