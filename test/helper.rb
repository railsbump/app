ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']

require 'cuba/test'
require_relative '../app'
